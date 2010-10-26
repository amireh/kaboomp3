#!/usr/bin/ruby

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

include Pixy::Utility

ActiveRecord::Base.establish_connection(YAML::load(File.open(File.join(ENV['APP_ROOT'], "config", "database.yml"))))

#Dir.chdir(File.expand_path(__FILE__))

temp = File.join("/Volumes/kandie", "test", "simulations", "snapshot_#{Time.now.to_i}")
FileUtils.mkdir_p(temp)

organizer = Pixy::Organizer.new()
organizer.showing_progress=true
stats, errors = organizer.simulate(Pixy::Library.first, temp)
nr_successes = stats[:nr_tracks] - stats[:failures]
prcnt_successes = ((nr_successes.to_f / stats[:nr_tracks].to_f).to_f * 100.0).to_i
prcnt_failures = ((stats[:failures].to_f / stats[:nr_tracks].to_f).to_f * 100.0).to_i

log "Elapsed time: #{stats[:timer][:elapsed]} seconds"
log "# tracks: #{stats[:nr_tracks]}"
log "# successes: #{nr_successes} (#{prcnt_successes}%)"
log "# failures : #{stats[:failures]} (#{prcnt_failures}%)"

puts errors.inspect

FileUtils.rm_rf(temp)
