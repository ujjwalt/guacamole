# -*- encoding: utf-8 -*-

require 'guacamole'
require 'guacamole/configuration'

require 'rails'

module Guacamole
  # Class to hook into Rails configuration and initializer
  # @api private
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'guacamole/railtie/database.rake'
    end

    config.guacamole = ::Guacamole::Configuration

    # We're not doing migrations (yet)
    config.send(:app_generators).orm :guacamole, migration: false

    initializer 'guacamole.load-config' do
      config_file = Rails.root.join('config', 'guacamole.yml')
      if config_file.file?
        Guacamole::Configuration.load config_file
      end
    end

    initializer 'guacamole.append-identity-map-middleware' do |app|
      app.middleware.use Guacamole::IdentityMap::Session
    end
  end
end
