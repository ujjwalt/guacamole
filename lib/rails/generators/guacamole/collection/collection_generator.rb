# -*- encoding : utf-8 -*-

require 'rails/generators/guacamole_generator'

module Guacamole
  module Generators
    class CollectionGenerator < Base
      desc 'Creates a Guacamole collection'

      check_class_collision suffix: 'Collection'

      def create_collection_file
        template 'collection.rb.tt', File.join('app/collections', class_path, "#{file_name}_collection.rb")
      end

      hook_for :test_framework
    end
  end
end
