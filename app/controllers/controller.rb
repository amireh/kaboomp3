module Pixy
  
  class InvalidState < Exception; end
  class InvalidTransition < Exception; end
  class InvalidView < Exception; end
  
  class Controller < Qt::Object
    include Pixy::Utility
    
    attr_reader :ui, :view, :overlays, :pages
    
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
    def initialize(ui, sheet_path)
      super()
      
      @ui = ui

      raise InvalidState if !loaded?
        
      # load the view
      @view = load_view(sheet_path, nil, @ui[:loader])
      
      raise InvalidView if @view.nil?

      # attach it to our main view
      @ui[:window].findChild(Qt::StackedWidget, "contentView").addWidget(@view)
      @ui[:window].findChild(Qt::StackedWidget, "contentView").setCurrentWidget(@view)
      
      @overlays, @pages = { }
      
      # bind our event handlers
      bind
    end

    # validates handles passed to us which we need to operate 
    def loaded?
      true unless @ui[:qt].nil? or @ui[:window].nil? or @ui[:loader].nil?
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
        @view.show
      end

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
    
    def clear_view
      
    end
    
  end
end