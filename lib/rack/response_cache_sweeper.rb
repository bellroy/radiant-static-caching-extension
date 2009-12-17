class Rack::ResponseCacheSweeper
  def initialize(app, cache_path)
    @app, @cache_path = app, cache_path
  end
  
  def call(env)
    unless ['GET', 'HEAD'].include? env['REQUEST_METHOD']
      CacheWriter.ensure_cache_dir
      FileUtils.rm_rf Dir.glob(File.join(@cache_path, '*'))
      %w(edit spider_attempt).each { |part| FileUtils.rm_rf File.join(@cache_path, ".last_#{part}") }
      FileUtils.touch File.join(@cache_path, '.last_edit')
    end
    @app.call(env)
  end
  
end