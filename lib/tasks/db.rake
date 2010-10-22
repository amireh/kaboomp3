require 'sqlite3'
require 'active_record'
require 'yaml'
require 'fileutils'
require 'linguistics'

namespace :db do
  task :default => :migrate

  desc "Generates a blank migration for a model"
  task :generate, :model do |t, args|
    Linguistics.use( :en )
  
    path = File.join(ENV['APP_ROOT'], "data", "migrations")
    model = args.model
    plural = "#{model.en.plural}"
  
    # prepare directory / file
    begin
      FileUtils.mkdir_p("#{path}")
      file = File.open(File.join(path, "#{Time.now.to_i}_create_#{plural}.rb"), "w+")
    rescue Exception => e
      puts "Could not make directory and/or open file at path ./#{path}"
      break
    end
  
    file <<
"class Create#{plural.capitalize} < ActiveRecord::Migration
  def self.up
    create_table :#{plural} do |t|
    end
  end

  def self.down
    drop_table :#{plural}
  end
end
"
    file.close
  
    puts "Generated migration for #{plural.capitalize} at #{file.path}"
  end

  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate(File.join("data", "migrations"), ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  task :environment do
    ActiveRecord::Base.establish_connection(YAML::load(File.open(File.join("config", "database.yml"))))
    ActiveRecord::Base.logger = Logger.new(File.open(File.join("log", "database.log"), 'a'))
  end
end # namespace :db