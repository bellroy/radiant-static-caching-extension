# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class StaticCachingExtension < Radiant::Extension
  version "0.8.0"
  description "Caches GET requests to disk, and purges on POST/PUT/DELETEs"
  url "http://github.com/tricycle/radiant-static-cache-extension"
  
  #TODO: put this somewhere more appropriate
  CACHE_CONTROL_PATH_PROC = proc do |env, res|
    if res[1].include? "Cache-Control"
      cache_controls = res[1]["Cache-Control"].split(',').collect(&:strip)
      unless (cache_controls & ['private', 'no-cache']).empty?
        return false
      end
    end
    Rack::ResponseCache::DEFAULT_PATH_PROC.call(env, res)
  end
  
  def activate
    gem "rack-contrib"
    require "rack/contrib/response_cache"
    static_cache_dir = defined?(STATIC_CACHE_DIR) ? STATIC_CACHE_DIR : "#{RAILS_ROOT}/public/radiant-cache"
  
    ActionController::Dispatcher.middleware.use Rack::ResponseCache, static_cache_dir, &CACHE_CONTROL_PATH_PROC
    ActionController::Dispatcher.middleware.use Rack::ResponseCacheSweeper, static_cache_dir
  end
  
  def deactivate
    ActionController::Dispatcher.middleware.delete Rack::ResponseCache
    ActionController::Dispatcher.middleware.delete Rack::ResponseCacheSweeper
  end
end
