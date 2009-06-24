# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ResponseCacheSweeperExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/response_cache_sweeper"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :response_cache_sweeper
  #   end
  # end
  
  def activate
    # admin.tabs.add "Response Cache Sweeper", "/admin/response_cache_sweeper", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Response Cache Sweeper"
  end
  
end
