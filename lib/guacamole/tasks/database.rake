# -*- encoding : utf-8 -*-

namespace :db do
  namespace :guacamole do
    desc "Purges all the collections of the database for the current environment"
    task :purge => :environment do
      puts "[ARANGODB] Purging all data from database '#{Guacamole.configuration.database.name}' ..."
      Guacamole.configuration.database.truncate
    end

    desc "Drops all the collections of the database for the current environment"
    task :drop => :environment do
      puts "[ARANGODB] Dropping the database '#{Guacamole.configuration.database.name}' ..."
      Guacamole.configuration.database.drop
    end

    desc "Create the database for the current environment"
    task :create => :environment do
      puts "[ARANGODB] Creating the database '#{Guacamole.configuration.database.name}' ..."
      Guacamole.configuration.database.create
    end
  end
end
