class ResponseCacheConfig
  cattr_accessor :cache_dir
  @@cache_dir = defined?(STATIC_CACHE_DIR) ? STATIC_CACHE_DIR : "#{RAILS_ROOT}/public/radiant-cache"
end