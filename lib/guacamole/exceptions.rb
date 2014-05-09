# -*- encoding : utf-8 -*-

module Guacamole
  class GenericError < StandardError; end
  class AQLNotSupportedError < GenericError
    def initialize(msg = 'AQL is an experimental feature. Please activate it in the config.')
      super
    end
  end
end
