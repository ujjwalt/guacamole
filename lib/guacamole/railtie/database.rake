# -*- encoding : utf-8 -*-

load 'guacamole/tasks/database.rake'

namespace :db do
  unless Rake::Task.task_defined?("db:drop")
    desc "Drops all the collections of the database for the current Rails.env"
    task :drop => "guacamole:drop"
  end

  unless Rake::Task.task_defined?("db:purge")
    desc "Purges all the collections of the database for the current Rails.env"
    task :purge => "guacamole:purge"
  end

  unless Rake::Task.task_defined?("db:seed")
    desc "Load the seed data from db/seeds.rb"
    task :seed => :environment do
      seed_file = File.join(Rails.root, "db", "seeds.rb")
      load(seed_file) if File.exist?(seed_file)
    end
  end

  unless Rake::Task.task_defined?("db:setup")
    desc "Create the database, and initialize with the seed data"
    task :setup => [ "db:create", "db:seed" ]
  end

  unless Rake::Task.task_defined?("db:reset")
    desc "Delete data and loads the seeds"
    task :reset => [ "db:drop", "db:seed" ]
  end

  unless Rake::Task.task_defined?("db:create")
    desc "Create the database"
    task :create => "guacamole:create"
  end

  unless Rake::Task.task_defined?("db:migrate")
    desc "Run the migrations for the current Rails.env (not yet implemented)"
    task :migrate => :environment do
      raise "ArangoDB doesn't support migrations. If you need to migrate your data you must roll your own solution."
    end
  end

  unless Rake::Task.task_defined?("db:schema:load")
    namespace :schema do
      task :load do
        raise "ArangoDB is schema-less, thus we cannot load any schema."
      end
    end
  end

  unless Rake::Task.task_defined?("db:test:prepare")
    namespace :test do
      task :prepare => "guacamole:purge"
    end
  end
end
