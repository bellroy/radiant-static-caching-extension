require File.expand_path(File.dirname(__FILE__) + '/../cache_writer')

namespace :cache do
  desc "Primes primary caches."
  task :prime => :environment do
    max_load = 1.5
    load_avg = File.read("/proc/loadavg") rescue nil
    
    # If we can't ascertain load, run it. If we can, run unless we're loaded.
    CacheWriter.prime! if !load_avg || load_avg.split.first.to_f < max_load
  end

  desc "Primes primary caches if stale."
  task :refresh do
    Rake::Task['cache:prime'].invoke unless CacheWriter.fresh?
  end
end
