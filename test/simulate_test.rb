ENV['APP_ROOT'] ||= File.expand_path("..")

$LOAD_PATH << File.join(ENV['APP_ROOT'], 'app') << File.join(ENV['APP_ROOT'], 'lib')

Dir.chdir(ENV['APP_ROOT'])

require 'rubygems'
require 'active_record'
require 'kaboom_exceptions'
require 'yaml'
require File.join('organizer')
require File.join('models', 'library')
require File.join('models', 'track')

ActiveRecord::Base.establish_connection(YAML::load(File.open(File.join(ENV['APP_ROOT'], "config", "database.yml"))))

#Dir.chdir(File.expand_path(__FILE__))

temp = File.join(ENV['APP_ROOT'], "test", "simulations", "snapshot_#{Time.now.to_i}")
FileUtils.mkdir_p(temp)

organizer = Pixy::Organizer.new()
organizer.showing_progress=false
stats = organizer.simulate(Pixy::Library.first, temp)
puts stats.inspect
