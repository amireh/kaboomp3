#!/usr/bin/ruby

require 'rubygems'
require 'fileutils'
require 'datamapper'
require 'dm-core'
require 'dm-migrations'
require 'do_sqlite3'
require 'qt4'
require 'qtuitools'


ENV['APP_ROOT'] ||= File.expand_path(File.dirname(__FILE__))

$LOAD_PATH << File.join(ENV['APP_ROOT'], 'app')

require File.join("lib", "utility")

Qt::debug_level=Qt::DebugLevel::Minimal

module Pixy
  class Pandemonium
  
    include Pixy::Utility

    @views = { 
      :intro => nil
    }
    
    @controllers = {
      :intro => nil
    }
    
    @ui_loader = nil
    
    attr_reader :window, :qt_app
    
    def setup

      # initialize Qt & the UI loader
      puts "initializing Qt"
      @qt_app = Qt::Application.new(ARGV)
      @ui_loader = Qt::UiLoader.new
      
      #puts ENV['APP_ROOT']
      puts Dir.pwd
      #DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/test.sqlite3")
      DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/test.db")
=begin
      DataMapper.setup(:default, {
        :adapter  => 'mysql',
        :host     => 'localhost',
        :username => 'root',
        :password => '',
        :database => "pandemonium"
      })
=end
      # Models
      puts "mounting models"
      require File.join(ENV['APP_ROOT'], 'app', 'models', 'model')
      Dir.new(File.join(ENV['APP_ROOT'], 'app', 'models')).entries.each do |file|
        puts "loading #{file}" if ruby_script?(file)
        require "models/#{file.gsub('.rb', '')}" if ruby_script?(file)
      end

      [Library, Repository, Genre, Artist, Album, Track].each do |model| model.auto_upgrade! end

      # create our controllers
      puts "loading controllers"
      Dir.new(File.join(ENV['APP_ROOT'], 'app', 'controllers')).entries.each do |file|
        require File.join("controllers", file.gsub('.rb', '')) if ruby_script?(file) 
      end

      # load our views
      @views = {
        :intro => Qt::File.new(File.join("app", "views", "main_window.ui"))
      }
      
      @controllers = {
        :intro => IntroController.new(@window, @views[:intro], @qt_app, @ui_loader)
      }
      
      puts "set up!"
    end

    def run
      begin
        setup    
        @controllers[:intro].attach
      rescue Exception => e
        puts("#{e.class}: #{e.message}")
        exit
      end
      
      @qt_app.exec
    end
  end # class Pandemonium
end # module Pixy

=begin


a = Qt::Application.new(ARGV)

#if ARGV.length == 0
#  exit
#end

#if ARGV.length == 1
  file = Qt::File.new(File.join("app", "views", "main_window.ui"))
  file.open(Qt::File::ReadOnly)

  loader = Qt::UiLoader.new
  window = loader.load(file, nil)
  file.close
  if (window.nil?)
    print "Error. Window is nil.\n"
    exit
  end
  window.show
  a.connect(a, SIGNAL('lastWindowClosed()'), a, SLOT('quit()'))
  a.exec
#end
=end

app = Pixy::Pandemonium.new
app.run()