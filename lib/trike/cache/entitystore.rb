module Trike
  module Cache
    class EntityStore < Radiant::Cache::EntityStore

      alias_method :body_path, :storage_path

      def slurp(body, &block)
        digest, size = super
        size
      end

      def write(body, content_type, normalized_url)
        filename = ['buf', $$, Thread.current.object_id].join('-')
        temp_file = storage_path(filename)
        size =
        File.open(temp_file, 'wb') { |dest|
          slurp(body) { |part| dest.write(part) }
        }

        key = generate_key(content_type, normalized_url)

        path = storage_path(key)


        if File.exist?(path)
          File.unlink temp_file
        else
          FileUtils.mkdir_p File.dirname(path), :mode => 0755
          FileUtils.mv temp_file, path
        end
        [key, size]

      end

      def generate_key(content_type, normalized_url)
        uri = URI::parse(normalized_url)

        ext  = File.extname(uri.path)
        path = uri.path
        path += "index" if (path  =~  /\/$/ || path.empty?)

        path += '?' + uri.query unless uri.query.blank?
        if ext.blank?
          path += ".html" if (content_type.nil? || content_type.starts_with?("text/html"))
        elsif not uri.query.blank?
          path += ext
        end
        path
      end

    end
  end
end

# Add our classes as fake constants in the right place
class Rack::Cache::EntityStore
  TRIKE = Trike::Cache::EntityStore
end
