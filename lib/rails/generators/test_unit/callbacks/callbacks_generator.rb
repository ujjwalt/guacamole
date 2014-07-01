# -*- encoding : utf-8 -*-

require 'rails/generators/guacamole_generator'

module TestUnit
  module Generators
    class CallbacksGenerator < ::Guacamole::Generators::Base
      def create_test_file
        template 'callbacks_test.rb.tt', File.join('test/callbacks', class_path, "#{file_name}_callbacks_test.rb")
      end
    end
  end
end
