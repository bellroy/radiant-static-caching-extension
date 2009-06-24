class Rack::ResponseCacheSweeper
  
  def initialize(app, cache_path)
    @app, @cache_path = app, cache_path
  end
  
  def call(env)
    unless ['GET', 'HEAD'].include? env['REQUEST_METHOD']
       FileUtils.rm_rf(@cache_path)
    end
    @app.call(env)
  end
  
end