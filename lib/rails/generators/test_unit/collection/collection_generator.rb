# -*- encoding : utf-8 -*-

require 'rails/generators/guacamole_generator'

module TestUnit
  module Generators
    class CollectionGenerator < ::Guacamole::Generators::Base
      def create_test_file
        template 'collection_test.rb.tt', File.join('test/collections', class_path, "#{file_name}_collection_test.rb")
      end
    end
  end
end
