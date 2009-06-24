namespace :radiant do
  namespace :extensions do
    namespace :response_cache_sweeper do
      
      desc "Runs the migration of the Response Cache Sweeper extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          ResponseCacheSweeperExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          ResponseCacheSweeperExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Response Cache Sweeper to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from ResponseCacheSweeperExtension"
        Dir[ResponseCacheSweeperExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(ResponseCacheSweeperExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end  
    end
  end
end
