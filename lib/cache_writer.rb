require 'nokogiri'
require 'rack/test'
require File.expand_path(File.dirname(__FILE__) + '/response_cache_config')

class CacheWriter
  include Rack::Test::Methods

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
    FileUtils.touch self.class.last_spider_attempt_path
    sitemap_exists? ? spider_sitemap : spider_homepage
  end

  class << self
    def prime!
      new.run
    end

    def refresh!
      prime! if last_spider_attempt.nil? || last_edit && last_edit > last_spider_attempt && last_edit < 20.minutes.ago
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
