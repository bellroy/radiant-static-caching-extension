require 'rack/cache/key'

module Trike
  module Cache
    class Key < Rack::Cache::Key

      def generate
        original_request = @request.dup #save original request. we only change it because super is using @request's path_info
        @request.path_info.sub!(/\/$/,"") #remove trailing slash
        key = super
        @request = original_request #restore original request state
        key
      end

    end
  end
end