# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ResponseCacheSweeperExtension < Radiant::Extension
  version "1.0"
  description "Rack to removes static cached files in a given directory for POST, PUTS and DELETE"
  url "http://github.com/tricycle/radiant-response-cache-sweeper-extension"
  
  def activate
    Rack
    Rack::ResponseCacheSweeper
    ActionController::Dispatcher.middleware.use Rack::ResponseCacheSweeper, "#{RAILS_ROOT}/public/radiant-cache"
  end
  
  def deactivate
    ActionController::Dispatcher.middleware.delete Rack::ResponseCacheSweeper
  end
end
