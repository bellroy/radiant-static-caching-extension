# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class StaticCachingExtension < Radiant::Extension
  version "1.0"
  description "Static caching (serve cached files through the webserver e.g. apache)"
  url "http://github.com/tricycle/radiant-static-caching-extension"
  
  # define_routes do |map|
  #   map.connect 'admin/static_caching/:action', :controller => 'admin/static_caching'
  # end
  
  def activate
    # admin.tabs.add "Static Caching", "/admin/static_caching", :after => "Layouts", :visibility => [:all]
    puts("Static Caching activated")
    ResponseCache.instance_eval { include StaticResponseCache }
  end
  
  def deactivate
    # admin.tabs.remove "Static Caching"
  end
  
end
