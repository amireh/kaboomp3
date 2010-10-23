#!/usr/bin/ruby

ENV['APP_ROOT'] ||= File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.join(ENV['APP_ROOT'], 'app') << File.join(ENV['APP_ROOT'], 'lib')

require 'rubygems'
require 'fileutils'
require 'active_record'
require 'qt4'
require 'qtuitools'
require 'utility'

module Pixy
  class Pandemonium
    include Pixy::Utility

    attr_reader :ui
  
    def setup

      @ui = { 
        :qt => nil,
        :loader => nil,
        :window => nil,
        :controllers => { 
          :intro => nil,
          :library => nil
        },
        :views => { 
          :intro => nil,
          :library => nil
        }
      }
      
      # initialize Qt & the UI loader
      log "initializing Qt"
      @ui[:qt] = Qt::Application.new(ARGV)
      @ui[:loader] = Qt::UiLoader.new
      Qt::debug_level=Qt::DebugLevel::Minimal
      
      # connect to our database
      ActiveRecord::Base.establish_connection(YAML::load(File.open(File.join(ENV['APP_ROOT'], "config", "database.yml"))))
      
      # load models
      log "mounting models"
      require File.join(path_to("models"), 'model')
      Dir.new(path_to("models")).entries.each do |file|
        require File.join(path_to("models"), file.gsub('.rb', '')) if ruby_script?(file)
      end

      # create our controllers
      log "loading controllers"
      Dir.new(path_to("controllers")).entries.each do |file|
        require File.join(path_to("controllers"), file.gsub('.rb', '')) if ruby_script?(file) 
      end

      # load our main window
      @ui[:window] = load_view(File.join(path_to("views"), "main_window.ui"), nil, @ui[:loader])
      
      @ui[:views] = {
        :intro => File.join(path_to("views"), "intro", "libraries.ui"),
        :library => File.join(path_to("views"), "library", "library.ui")
      }
      
      @ui[:controllers] = {
        :intro => IntroController.new(@ui, @ui[:views][:intro]),
        :library => LibraryController.new(@ui, @ui[:views][:library])
      }
      
      log "set up!"
    end

    def run!
      begin
        setup
        @ui[:window].show
        @ui[:controllers][:intro].attach
      rescue Exception => e
        log("#{e.class}: #{e.message}")
        exit
      end
      
      @ui[:qt].exec
    end
  end # class Pandemonium
end # module Pixy