class Rack::ResponseCacheSweeper
  def initialize(app, cache_path)
    @app, @cache_path = app, cache_path
  end
  
  def call(env)
    unless ['GET', 'HEAD'].include? env['REQUEST_METHOD']
       FileUtils.rm_rf(File.join(@cache_path, '*'))
       FileUtils.touch(File.join(@cache_path, '.last_edit'))
    end
    @app.call(env)
  end
  
end