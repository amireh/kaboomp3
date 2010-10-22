module Pixy
  class IntroController < Controller
  
    slots :quit, :show_create_library, :create_library, :cancel_create_library, :goto_library

    def initialize(ui, path)
      super(ui, path)
      
      # load our overlays
      overlay_path = File.join(path_to("overlays"), "create_library.ui")
      @overlays[:create_library] = load_view(overlay_path, @ui[:window], @ui[:loader])
      
      # and bind their event handlers
      bind_overlays
    end
    
    protected
    
    def bind
      connect(
        @view.findChild(Qt::PushButton, "button_createLibrary"), 
        SIGNAL('clicked()'), 
        self, 
        SLOT('show_create_library()')
      )
  
      connect(
        @view.findChild(Qt::PushButton, "button_test"), 
        SIGNAL('clicked()'),
        self, 
        SLOT('goto_library()')
      )
      
    end
    
    
    def bind_overlays
      connect(
        @overlays[:create_library], 
        SIGNAL('accepted()'), 
        self, 
        SLOT('create_library()')
      )
      
      connect(
        @overlays[:create_library], 
        SIGNAL('rejected()'), 
        self, 
        SLOT('cancel_create_library()')
      )      
    end

    private
    
    def show_create_library
      @overlays[:create_library].show
    end
    
    def create_library
      log "gonna create library yo!"
    end
    
    def cancel_create_library
      log "cancelled !"
    end
    
    def goto_library
      transition(@ui[:controllers][:library])
    end
    
        
  end # class IntroController
end # module Pixy

