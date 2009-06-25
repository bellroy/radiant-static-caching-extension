# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class StaticCachingExtension < Radiant::Extension
  version "1.0"
  description "Caches GET requests to disk, and purges on POST/PUT/DELETEs"
  url "http://github.com/tricycle/radiant-static-cache-extension"
  
  def activate
    gem "rack-contrib"
    require "rack/contrib/response_cache"
    static_cache_dir = defined?(STATIC_CACHE_DIR) ? STATIC_CACHE_DIR : "#{RAILS_ROOT}/public/radiant-cache"
    ActionController::Dispatcher.middleware.use Rack::ResponseCache, static_cache_dir
    ActionController::Dispatcher.middleware.use Rack::ResponseCacheSweeper, static_cache_dir
  end
  
  def deactivate
    ActionController::Dispatcher.middleware.delete Rack::ResponseCache
    ActionController::Dispatcher.middleware.delete Rack::ResponseCacheSweeper
  end
end
