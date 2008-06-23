class StaticCachingExtension < Radiant::Extension
  version "1.0"
  description "Static caching (serve cached files through the webserver e.g. apache)"
  url "http://github.com/tricycle/radiant-static-caching-extension"
  
  def activate
    ResponseCache.instance_eval { include StaticResponseCache }
  end
  
  def deactivate
  end
  
end
