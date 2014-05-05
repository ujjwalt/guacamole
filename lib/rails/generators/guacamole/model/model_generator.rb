# -*- encoding : utf-8 -*-

require 'rails/generators/guacamole_generator'

module Guacamole
  module Generators
    class ModelGenerator < Base
      desc 'Creates a Guacamole model'
      argument :attributes, type: :array, default: [], banner: 'field:type field:type'

      check_class_collision

      class_option :parent, type: :string, desc: 'The parent class for the generated model'

      def create_model_file
        template 'model.rb.tt', File.join('app/models', class_path, "#{file_name}.rb")
      end

      hook_for :test_framework
      hook_for :collection, aliases: '-c', type: :boolean, default: true do |instance, collection|
        instance.invoke collection, [instance.name.pluralize]
      end
    end
  end
end
