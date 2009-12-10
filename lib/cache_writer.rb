require 'nokogiri'
require 'rack/test'

class CacheWriter
  include Rack::Test::Methods

  attr_reader :app

  def initialize
    # Turn off existing caching so the request isn't intercepted.
    ActionController::Dispatcher.middleware.delete Radiant::Cache
    # ActionController::Base.perform_caching = false
    
    # Construct the app for charging our cache.
    @app = Rack::Builder.new {
      map "/" do
        run ActionController::Dispatcher.new
      end
    }.to_app
  end
  
  def run
    sitemap_exists? ? spider_sitemap : spider_homepage
  end

protected

  def spider_sitemap
    puts "Spidering sitemap:"
    return false
  end

  def spider_homepage
    puts "Spidering homepage:"
    print "\tFetching index..."
    get '/'
    if last_response.ok?
      puts "done."
      index = Nokogiri::HTML last_response.body
      index.css('a[href^="/articles"]').each do |link|
        print "\tFetching #{link[:href]}..."
        get link[:href]
        if last_response.ok?
          puts "done."
        else
          puts "error."
          return false
        end
      end
      return true
    else
      puts "error."
      return false
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
