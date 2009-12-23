require File.expand_path(File.dirname(__FILE__) + '/../cache_writer')

namespace :cache do
  desc "Primes primary caches."
  task :prime => :environment do
    max_load = ENV['MAX_LOAD'] && ENV['MAX_LOAD'].to_f
    load_avg = File.read("/proc/loadavg") rescue nil
    
    # If we can't ascertain load, run it. If we can, run unless we're loaded.
    CacheWriter.prime! unless max_load && load_avg && load_avg.split.first.to_f > max_load
  end

  desc "Primes primary caches if stale."
  task :refresh do
    Rake::Task['cache:prime'].invoke unless CacheWriter.fresh?
  end
end
