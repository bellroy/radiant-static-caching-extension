namespace :radiant do
  namespace :extensions do
    namespace :static_html_caching do
      
      desc "Runs the migration of the Static Html Caching extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          StaticHtmlCachingExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          StaticHtmlCachingExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Static Html Caching to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[StaticHtmlCachingExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(StaticHtmlCachingExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
