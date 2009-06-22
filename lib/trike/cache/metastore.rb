module Trike
  module Cache
    class MetaStore < Radiant::Cache::MetaStore

      def store(request, response, entity_store)
        key = cache_key(request)
        stored_env = persist_request(request)

        # write the response body to the entity store if this is the
        # original response.
        if response.headers['X-Content-Digest'].nil?
          # The line below is the only deffierece from Rack::Cache::MetaStore
          digest, size = entity_store.write(response.body, response.headers['Content-Type'], key)
          response.headers['X-Content-Digest'] = digest
          response.headers['Content-Length'] = size.to_s unless response.headers['Transfer-Encoding']
          response.body = entity_store.open(digest)
        end

        # read existing cache entries, remove non-varying, and add this one to
        # the list
        vary = response.vary
        entries =
        read(key).reject do |env,res|
          (vary == res['Vary']) &&
          requests_match?(vary, env, stored_env)
        end

        headers = persist_response(response)
        headers.delete 'Age'

        entries.unshift [stored_env, headers]
        write key, entries
        key
      end

    end

  end
end

# Add our classes as fake constants in the right place
class Rack::Cache::MetaStore
  TRIKE = Trike::Cache::MetaStore
end
