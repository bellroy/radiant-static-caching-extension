# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class StaticHtmlCachingExtension < Radiant::Extension
  version "1.0"
  description "Static HTML caching (serve cached files through the webserver e.g. apache)"
  url "http://github.com/tricycle/radiant-static-html-caching"
  
  # define_routes do |map|
  #   map.connect 'admin/static_html_caching/:action', :controller => 'admin/static_html_caching'
  # end
  
  def activate
    # admin.tabs.add "Static Html Caching", "/admin/static_html_caching", :after => "Layouts", :visibility => [:all]
    puts("Static HTML Caching activated")
    ResponseCache.instance_eval { include StaticResponseCache }
  end
  
  def deactivate
    # admin.tabs.remove "Static Html Caching"
  end
  
end
