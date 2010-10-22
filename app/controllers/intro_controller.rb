module Pixy
  class IntroController < Controller
    attr_reader :overlays
    
    slots :quit, :show_create_library, :create_library, :cancel_create_library

    public
    
    def initialize(window, view, app, loader)
      super(window, view, app, loader)
      
      @overlays = { :create_library => nil }
      sheet = Qt::File.new(File.join(path_to("views"), "create_library.ui"))
      sheet.open(Qt::File::ReadOnly)
      @overlays[:create_library] = @loader.load(sheet, @window)
      sheet.close
      
    end
    
    def show_create_library
      @overlays[:create_library].show
    end
    
    def create_library
      log "gonna create library yo!"
    end
    
    def cancel_create_library
      log "cancelled !"
    end
    
    
    def quit
      log "Quitting!"
    end
    
    def attach
      super()
      
      @overlays[:create_library].setParent(@window)
      @overlays[:create_library].hide
    end
    
    protected
    
    def bind
      @app.connect(
        @window.findChild(Qt::PushButton, "button_createLibrary"), 
        SIGNAL('clicked()'), 
        self, 
        SLOT('show_create_library()')
      )
 
      @app.connect(
        @overlays[:create_library], 
        SIGNAL('accepted()'), 
        self, 
        SLOT('create_library()')
      )
      
      @app.connect(
        @overlays[:create_library], 
        SIGNAL('rejected()'), 
        self, 
        SLOT('cancel_create_library()')
      )
      
    end
    
    def unbind
    end
    
  end
end

