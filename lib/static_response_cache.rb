module StaticResponseCache
  
  def self.included(base)
    base.instance_eval do
      alias_method_chain :cache_page, :static
    end
  end

  def cache_page_with_static(metadata, content, path)
    cache_path = static_cache_path(path)
    metadata = YAML.load(metadata)
    if File.extname(cache_path).blank? &&
      (metadata['Content-Type'].nil? ||
        metadata['Content-Type'].starts_with?('text/html'))
      cache_path = cache_path + '.html'
    end
    logger.info("Caching Page: #{cache_path}")
    logger.info("metadata: #{metadata.inspect}")
    # ensure path exists
    FileUtils.makedirs(File.dirname(cache_path))
    File.open(cache_path, 'wb') { |f| f.write(content) }
  end

  def static_cache_path(path)
    cache_path = page_cache_path(path)
    if cache_path.ends_with?('_site-root')
      cache_path.sub!(/_site-root$/, 'index')
    end
    cache_path
  end

end
