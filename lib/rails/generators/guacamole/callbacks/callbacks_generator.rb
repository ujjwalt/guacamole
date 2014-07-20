# -*- encoding : utf-8 -*-

require 'rails/generators/guacamole_generator'

module Guacamole
  module Generators
    class CallbacksGenerator < Base
      desc 'Creates a Guacamole callback class'

      class_option :model_class, type: :string, required: false, banner: 'CLASS_NAME | Default: NAME', desc: 'The model class this callback is used for.'

      check_class_collision

      def create_callback_file
        model_file_name = (options[:model_class] || class_name).underscore
        inject_into_file "app/models/#{model_file_name}.rb",
          "\n\n  callbacks :#{class_name.underscore}_callbacks",
          after: 'include Guacamole::Model'

        template 'callbacks.rb.tt', File.join('app/callbacks', class_path, "#{file_name}_callbacks.rb")
      end

      hook_for :test_framework
    end
  end
end
