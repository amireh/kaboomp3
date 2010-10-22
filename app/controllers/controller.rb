module Pixy
  
  class InvalidState < Exception; end
  class InvalidTransition < Exception; end
  class InvalidView < Exception; end
  
  class Controller < Qt::Object
    
    include Pixy::Utility
    
    attr_reader :app, :loader, :window, :view, :sheet, :overlays
    
    #################################################################################
    # loads the controller
    # 
    # arguments:
    # => window: handle to the main display window to which @view will be attached
    # => loader: handle to Qt::UiLoader which allows us to load .ui sheets on runtime
    # => app: handle to the Qt App delegate, will be used for binding slots
    #
    # WARNING: @view MUST be set by children with the path to the .ui sheet
    #
    def initialize(app, loader, window, sheet)
      super()
      
      @window = window
      @sheet = sheet
      @app = app
      @loader = loader
      @view = nil

    end
    
    # is this controller ready to manage its view?
    def loaded?
      return @view || (@app && @window && @loader && @sheet)
    end
    
    # is the view currently displayed?
    def attached?
      return @view && @view.visible?
    end
    
    #################################################################################
    # attaches view to display window
    #
    # call this when you need to "activate" this controller's view;
    # the separation of controller loading and the attachment of its
    # view provides flexibility
    # 
    def attach
      raise InvalidState if !loaded? # make sure we're populated

      unless attached?
        @sheet = Qt::File.new(@sheet)
        @sheet.open(Qt::File::ReadOnly)
        @view = @loader.load(@sheet, @window)
        @sheet.close
        
        raise InvalidView if @window.nil?
      end
      
      @view.show
      bind
    end

    # switches from current view to the destination controller's
    def transition(controller)
      raise InvalidTransition unless controller.loaded?
      
      detach if attached?
      
      controller.attach
    end
  
    protected
    
    # removes current view from display; called prior to a transition
    def detach
      unbind
      @view.hide
    end
    
    # hooks slots to signals
    # NOTE: must be implemented by children
    def bind
    end
    
    # unhooks signals from slots
    # NOTE: must be implemented by children
    def unbind
    end
    
    def attachOverlay(overlay)
    end
    
    def detachOverlay(overlay)
    end
    
  end
end