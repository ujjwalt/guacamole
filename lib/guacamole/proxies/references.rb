# -*- encoding : utf-8 -*-

require 'guacamole/proxies/proxy'

module Guacamole
  module Proxies
    # The {References} proxy is used to represent the 'many' in one-to-many relations.
    class References < Proxy
      def initialize(ref, document)
        init nil,
             -> { DocumentModelMapper.collection_for(ref).by_key(document["#{ref}_id"]) }
      end
    end
  end
end
