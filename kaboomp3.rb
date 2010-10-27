#!/usr/bin/ruby

ENV['APP_ROOT'] ||= File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.join(ENV['APP_ROOT'], 'lib')
$LOAD_PATH << File.join(ENV['APP_ROOT'], 'app')  
$LOAD_PATH << File.join(ENV['APP_ROOT'], 'app', 'controllers')
$LOAD_PATH << File.join(ENV['APP_ROOT'], 'app', 'models')

require 'rubygems'
require 'fileutils'
require 'active_record'
require 'Qt4'
require 'qtuitools'
require 'kaboomp3/utility'
require 'kaboomp3/exceptions'
require 'kaboomp3/organizer'
require 'controller'

module Pixy
  class Kaboomp3 < Qt::Object
    include Pixy::Utility

    SnapshotsDestination = File.join(ENV['APP_ROOT'], "tmp")
    
    @@_instance = nil
    
    slots 'cleanup()'
    
    attr_reader :ui, :organizer

    public
    
    def self.instance
      @@_instance = Kaboomp3.new if @@_instance.nil?
    
      @@_instance
    end
    
    def run!
      begin
        @ui[:window].show
        @ui[:controllers][:intro].attach
      rescue Exception => e
        log "#{e.class}: #{e.message}"
        exit
      end
      
      @ui[:qt].exec
    end
    
    protected
    
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
        },
        :resources => {
          :master => "resources.rcc"
        }
      }
      
      log "initializing Organizer"
      @organizer = Organizer.new()
      
      # initialize Qt & the UI loader
      log "initializing Qt"
      @ui[:qt] = Qt::Application.new(ARGV)
      @ui[:loader] = Qt::UiLoader.new
      Qt::debug_level=Qt::DebugLevel::Minimal
      
      # load resources
      @ui[:resources].each_pair { |key, path| 
        log "loading resource key: #{key} from file: #{path}"; 
        Qt::Resource.registerResource(File.join(ENV['APP_ROOT'], "resources", path)) 
      }
      
      # connect to our database
      ActiveRecord::Base.establish_connection(YAML::load(File.open(File.join(ENV['APP_ROOT'], "config", "database.yml"))))
      
      # load models
      log "mounting models"
      Dir["#{File.join(path_to('models'), '*.rb')}"].each { |file| require file.gsub('.rb', '') }

      # create our controllers
      log "loading controllers"
      Dir["#{File.join(path_to('controllers'), '*.rb')}"].each { |file| require file.gsub('.rb', '') }

      # load our main window
      # note: load_view() is a helper found in Pixy::Utility
      @ui[:window] = load_view(File.join(path_to("views"), "main_window.ui"), nil, @ui[:loader])
      
      @ui[:views] = {
        :intro => File.join(path_to("views"), "libraries", "index.ui"),
        :libraries => File.join(path_to("views"), "libraries", "show.ui")
      }
      
      @ui[:controllers] = {
        :intro => IntroController.new(@ui, @ui[:views][:intro]),
        :libraries => LibraryController.new(@ui, @ui[:views][:libraries])
      }
      
      connect(@ui[:qt], SIGNAL('lastWindowClosed()'), self, SLOT('cleanup()'))
      
      log "set up!"
    end
    
    private
    
    def initialize()
      super()
      
      # BUGFIX: the unless? control is there to prevent components loaded in the setup() routine
      # (such as controllers) from triggering a recursive referencing loop by calling 
      # Kaboomp3.instance during their init routines
      setup# unless setting_up?
    end
    
    def cleanup()
      log "cleaning up my mess..."
      FileUtils.rm_rf(Dir.glob(File.join(SnapshotsDestination,"*")))
      log "oke, bye!"
    end
  end # class Kaboomp3
end # module Pixy

Pixy::Kaboomp3.instance.run!
