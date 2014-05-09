# -*- encoding : utf-8 -*-

module Guacamole
  class GenericError < StandardError; end
  class AQLNotSupportedError < GenericError
    def initialize(msg = 'AQL is an experimental feature. Please activate it in the config: https://github.com/triAGENS/guacamole#experimental-aql-support')
      super
    end
  end
end
