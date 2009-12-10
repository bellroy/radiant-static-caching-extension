# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class StaticCachingExtension < Radiant::Extension
  version "0.8.0"
  description "Caches GET requests to disk, and purges on POST/PUT/DELETEs"
  url "http://github.com/tricycle/radiant-static-cache-extension"

  STATIC_CACHE_DIR = "#{RAILS_ROOT}/public/radiant-cache" unless defined?(STATIC_CACHE_DIR)

  def activate
    gem "tricycle-rack-contrib"
    require "rack/contrib/response_cache"

    ActionController::Dispatcher.middleware.use Rack::ResponseCache, STATIC_CACHE_DIR
    ActionController::Dispatcher.middleware.use Rack::ResponseCacheSweeper, STATIC_CACHE_DIR
  end

  def deactivate
    ActionController::Dispatcher.middleware.delete Rack::ResponseCache
    ActionController::Dispatcher.middleware.delete Rack::ResponseCacheSweeper
  end
end
