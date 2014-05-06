# -*- encoding : utf-8 -*-

require 'rails/generators/guacamole/collection/collection_generator.rb'

module Rails
  module Generators
    class CollectionGenerator < Guacamole::Generators::CollectionGenerator
      def self.source_root
        File.expand_path("../../guacamole/#{generator_name}/templates", File.dirname(__FILE__))
      end
    end
  end
end
