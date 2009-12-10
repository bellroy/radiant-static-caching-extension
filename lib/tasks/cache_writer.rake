namespace :cache do
  desc "Primes primary caches."
  task :prime => :environment do
    CacheWriter.prime!
  end

  desc "Primes primary caches if stale."
  task :refresh => :environment do
    CacheWriter.refresh!
  end
end