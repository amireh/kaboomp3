#!/usr/bin/ruby

ENV['APP_ROOT'] ||= File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.join(ENV['APP_ROOT'], 'app')

require 'rubygems'
require 'fileutils'
require 'active_record'
require 'qt4'
require 'qtuitools'
require File.join(ENV['APP_ROOT'], "lib", "utility")

Qt::debug_level=Qt::DebugLevel::Minimal

module Pixy
  class Pandemonium
    include Pixy::Utility

    attr_reader :ui
  
    def setup

      @ui = { 
        :app => nil,
        :loader => nil,
        :window => nil,
        :controllers => { 
          :intro => nil
        },
        :views => { 
          :intro => nil
        }
      }
      
      # initialize Qt & the UI loader
      log "initializing Qt"
      @ui[:app] = Qt::Application.new(ARGV)
      @ui[:loader] = Qt::UiLoader.new
      
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
      sheet = Qt::File.new(File.join(path_to("views"), "main_window.ui"))
      sheet.open(Qt::File::ReadOnly)
      @ui[:window] = @ui[:loader].load(sheet, nil)
      sheet.close

      @ui[:views] = {
        :intro => File.join(path_to("views"), "intro_screen.ui")
      }
      
      @ui[:controllers] = {
        :intro => IntroController.new(@ui[:app], @ui[:loader], @ui[:window], @ui[:views][:intro])
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
      
      @ui[:app].exec
    end
  end # class Pandemonium
end # module Pixy