# -*- encoding : utf-8 -*-

require 'rails/generators/guacamole_generator'

module Rspec
  module Generators
    class CallbacksGenerator < ::Guacamole::Generators::Base
      def create_collection_spec
        template 'callbacks_spec.rb.tt', File.join('spec/callbacks', class_path, "#{file_name}_callbacks_spec.rb")
      end
    end
  end
end

