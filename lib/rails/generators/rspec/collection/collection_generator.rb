# -*- encoding : utf-8 -*-

require 'rails/generators/guacamole_generator'

module Rspec
  module Generators
    class CollectionGenerator < ::Guacamole::Generators::Base
      def create_collection_spec
        template 'collection_spec.rb.tt', File.join('spec/collections', class_path, "#{file_name}_collection_spec.rb")
      end
    end
  end
end
