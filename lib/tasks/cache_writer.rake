require File.expand_path(File.dirname(__FILE__) + '/../cache_writer')

namespace :cache do
  desc "Primes primary caches."
  task :prime => :environment do
    CacheWriter.prime!
  end

  desc "Primes primary caches if stale."
  task :refresh do
    Rake::Task['cache:prime'].invoke unless CacheWriter.fresh?
  end
end