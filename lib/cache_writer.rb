require 'nokogiri'
require 'rack/test' # required for #get below
require File.expand_path(File.dirname(__FILE__) + '/response_cache_config')

class CacheWriter
  include Rack::Test::Methods # required for #get below

  attr_reader :app

  def initialize
    # Turn off existing caching so the request isn't intercepted.
    # ActionController::Dispatcher.middleware.delete Radiant::Cache
    # ActionController::Base.perform_caching = false

    # Construct the app for charging our cache.
    @app = Rack::Builder.new {
      map "/" do
        # use Rails::Rack::Static # Kept commented because we might hit the file cache when making requests.
        run ActionController::Dispatcher.new
      end
    }.to_app
  end

  def run
    self.class.ensure_cache_dir
    raise "No /sitemap.xml found" unless sitemap_exists?
    FileUtils.touch self.class.last_spider_attempt_path
    spider_sitemap
  end

  class << self
    def cache_dir_exists?
      File.exists?(ResponseCacheConfig.cache_dir) && File.stat(ResponseCacheConfig.cache_dir).directory?
    end

    def ensure_cache_dir
      FileUtils.mkdir_p ResponseCacheConfig.cache_dir unless cache_dir_exists?
    end

    def prime!
      Tempfile.open('radiant_sites_static_cache_lock') do
        new.run
      end
    end

    def prime_with_locking!(max_spiders)
      spiders = Dir.glob(File.join(Dir::tmpdir, 'radiant_sites_static_cache_lock*'))
      prime! if spiders.length < max_spiders
    end

    def fresh?
      if last_edit
        if last_edit < 20.minutes.ago
          last_spider_attempt && last_spider_attempt > last_edit
        else
          true
        end
      else
        last_spider_attempt.present?
      end
    end

    %w(edit spider_attempt).each do |event|
      define_method("last_#{event}_path") do
        File.join(ResponseCacheConfig.cache_dir, ".last_#{event}")
      end

      define_method("last_#{event}") do
        path = send("last_#{event}_path")
        File.mtime path if File.exists? path
      end
    end
  end

protected

  def spider_sitemap
    puts "Spidering sitemap:"
    @sitemap.css('urlset url loc').each { |url| ping_path URI.parse(url).path }
  end

  def spider_homepage
    puts "Spidering homepage:"
    print "\tFetching index..."
    get '/'
    if last_response.ok?
      puts "done."
      index = Nokogiri::HTML last_response.body
      index.css('a[href^="/articles"]').each { |link| ping_path link[:href] }
      return true
    else
      puts "error."
      raise "Couldn't fetch index."
    end
  end

  def ping_path(path)
    print "\tFetching #{path}..."
    get path
    if last_response.ok?
      puts "done."
    else
      puts "error."
      raise "Couldn't fetch #{path}."
    end
  end

  def sitemap_exists?
    print "Checking for sitemap..."
    get '/sitemap.xml'
    if last_response.ok?
      puts "found."
      @sitemap = Nokogiri::XML last_response.body
      true
    else
      puts "missing."
      false
    end
  end
end
