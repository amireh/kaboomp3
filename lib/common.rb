$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..')
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'app')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'
require 'datamapper'
require 'fileutils'

# Models
Dir.new(File.join(ENV['APP_ROOT'], 'app', 'models')).entries.each do |file|
  # load files that match the format [string].rb and do not start with a .
  require "models/#{file.gsub('.rb', '')}" and puts "loading model #{file}..." unless (file =~ /\A[^\.].(.)*.(\.rb)\z/) == nil
end

# Controllers
Dir.new(File.join(ENV['APP_ROOT'], 'app', 'controllers')).entries.each do |file|
  require "controllers/#{file.gsub('.rb', '')}" and puts "loading controller #{file}..." unless (file =~ /\A[^\.].(.)*.(\.rb)\z/) == nil
end

module Pixy

  @@init = false
  
  def self.log(msg, caller)
    if !@@init then
      @@logger = File.open("log.out", "w+")
    	@@logger.write("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n")
    	@@logger.write("+                           Pandemonium                             +\n")
    	@@logger.write("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n")
    	@@logger.flush
    	@@init = true
    end      
    
    @@logger.write( "+ #{caller.class.name.gsub("Pixy::", "")}: #{msg}\n" )
    @@logger.flush
  end
  
  DataMapper.setup(:default, {
    :adapter  => 'sqlite',
    :host     => 'localhost',
    :username => 'root' ,
    :password => '',
    :database => 'db/pandemonium'
    })

  [Library, Repository, Genre, Artist, Album, Track].each do |model| model.auto_upgrade! end
  
end

#Pixy.quickfix