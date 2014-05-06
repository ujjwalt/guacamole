# -*- encoding : utf-8 -*-

require 'rails/generators/guacamole_generator'

module Guacamole
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      desc 'Creates a Guacamole configuration file at config/guacamole.yml'

      argument :database_name, type: :string, optional: true

      def self.source_root
        @_guacamole_source_root ||= File.expand_path('../templates', __FILE__)
      end

      def app_name
        Rails.application.class.parent.to_s.underscore
      end

      def create_config_file
        template 'guacamole.yml', File.join('config', 'guacamole.yml')
      end
    end
  end
end
