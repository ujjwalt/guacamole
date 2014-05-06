# -*- encoding : utf-8 -*-

require 'guacamole/proxies/proxy'

module Guacamole
  module Proxies
    # The {ReferencedBy} proxy is used to represent the 'one' in one-to-many relations.
    class ReferencedBy < Proxy
      def initialize(ref, model)
        init model,
             -> { DocumentModelMapper.collection_for(ref).by_example("#{model.class.name.underscore}_id" => model.key) }
      end
    end
  end
end
