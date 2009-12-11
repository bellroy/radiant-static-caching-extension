# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class StaticCachingExtension < Radiant::Extension
  version "0.8.0"
  description "Caches GET requests to disk, and purges on POST/PUT/DELETEs"
  url "http://github.com/tricycle/radiant-static-cache-extension"

  def activate
    gem "tricycle-rack-contrib"
    require "rack/contrib/response_cache"

    @radiant_cache = ActionController::Dispatcher.middleware.delete Radiant::Cache
    ActionController::Dispatcher.middleware.use Rack::ResponseCache, ResponseCacheConfig.cache_dir
    ActionController::Dispatcher.middleware.use Rack::ResponseCacheSweeper, ResponseCacheConfig.cache_dir
  end

  def deactivate
    ActionController::Dispatcher.middleware.delete Rack::ResponseCacheSweeper
    ActionController::Dispatcher.middleware.delete Rack::ResponseCache
    ActionController::Dispatcher.middleware.use @radiant_cache if @radiant_cache
  end
end
