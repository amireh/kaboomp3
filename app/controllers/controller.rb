module Pixy
  
  class InvalidState < Exception; end
  class InvalidTransition < Exception; end
  class InvalidView < Exception; end
  
  class Controller
    
    include Pixy::Utility
    
    attr_reader :window, :view, :app, :loader
    
    # loads the controller
    # 
    # arguments:
    # => window: handle to the main display window to which view will be attached
    # => view: path to the Qt UI file (expectedly under app/views)
    # => app: handle to the Qt App delegate
    def initialize(window, view, app, loader)
      @window = window
      @view = view
      @app = app
      @loader = loader
    end
    
    # is this controller ready to manage its view?
    def loaded?
      return @window || (@app && @view)
    end
    
    # is the view currently displayed?
    def attached?
      return @window && @window.visible?
    end
    
    # attaches view to display window
    #
    # call this when you need to "activate" this controller's view;
    # the separation of controller loading and the attachment of its
    # view provides flexibility
    def attach
      raise InvalidState if !loaded? # make sure we're populated

      unless attached?  
        @view.open(Qt::File::ReadOnly)
        @window = @loader.load(@view, @window)
        @view.close
        
        raise InvalidView if @window.nil?
      end
      
      @window.show and bind
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
      @window.hide
    end
    
    # hooks slots to signals
    # NOTE: must be implemented by children
    def bind
    end
    
    # unhooks signals from slots
    # NOTE: must be implemented by children
    def unbind
    end
        
  end
end