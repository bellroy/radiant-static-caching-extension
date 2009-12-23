require File.expand_path(File.dirname(__FILE__) + '/../cache_writer')

namespace :cache do
  desc "Primes primary caches."
  task :prime => :environment do
    max = ENV['MAX_SPIDERS'].present? && ENV['MAX_SPIDERS'].to_i
    max ? CacheWriter.prime_with_locking!(max) : CacheWriter.prime!
  end

  desc "Primes primary caches if stale."
  task :refresh do
    Rake::Task['cache:prime'].invoke unless CacheWriter.fresh?
  end
end
