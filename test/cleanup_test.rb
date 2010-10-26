#!/usr/bin/ruby

ENV['APP_ROOT'] ||= File.expand_path("..")

$LOAD_PATH << File.join(ENV['APP_ROOT'], 'lib')

Dir.chdir(ENV['APP_ROOT'])

require 'rubygems'
require 'active_record'
require 'yaml'
require File.join('kaboomp3', 'utility')
require File.join('app', 'models', 'library')
require File.join('kaboomp3', 'exceptions')
require File.join('kaboomp3', 'organizer')

include Pixy::Utility

ActiveRecord::Base.establish_connection(YAML::load(File.open(File.join(ENV['APP_ROOT'], "config", "database.yml"))))

organizer = Pixy::Organizer.new()
organizer.recursive_rmdir("/Volumes/kandie/iPod_Music")