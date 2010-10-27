module Pixy
    
  #################################################################################
  # Controllers have a set of views, controlled by a master view.
  # Views can have pages as children elements, which in turn can contain
  # other elements and pages as well.
  # Children can subclass the Controller to not only bind their handlers, but
  # also define their subviews / subpages.
  #
  # Loading a controller happens in two stages:
  #
  # @ Creation:
  # => the controller loads its views and pages, obtains handles to their
  # => elements, and optionally, binds its main view's signal emitters
  #
  # @ Attachment to display:
  # => mainly deals with forcing default values to view elements, and binding
  # => the rest of the elements (see bind_deferred()), and carrying out 
  # => controller-specific logic
  #
  # Controllers can transition between each other on fixed signals, which 
  # invokes their attach() routine.
  
  class Controller < Qt::Object
    include Pixy::Utility
    
    attr_reader :ui, :canvas, :pages, :views, :bound
    
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
      
      @views = { }
      @pages = { }
      
      # load the view
      @views = { 
        :master => load_view(sheet_path, nil, @ui[:loader])
      }

      raise InvalidView if @views[:master].nil?

      # make sure our we're hidden
      @views[:master].hide
      
      # add us to the main view's pages
      @ui[:window].findChild(Qt::StackedWidget, "viewContent").addWidget(@views[:master])
      
      # finally, bind our event handlers
      @bound = false
      bind
    end

    # validates handles passed to us which we need to operate 
    def loaded?
      true unless @ui[:qt].nil? or @ui[:window].nil? or @ui[:loader].nil?
    end
    
    # is the view currently displayed?
    def attached?
      return @views[:master] && @views[:master].visible?
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

      #unless attached?
        @ui[:window].findChild(Qt::StackedWidget, "viewContent").setCurrentWidget(@views[:master])
      #end

      # subviews elements may be bound here
      bind_deferred unless bound?
    end

    # switches from current view to the destination controller's
    def transition(controller)
      raise InvalidTransition unless controller.loaded?
      
      detach if attached?
      
      controller.attach
    end
  
    def cleanup
      
    end
    
    protected
    
    # removes current view from display; called prior to a transition
    def detach
      @views[:master].hide
    end
    
    # hooks slots to signals
    # NOTE: must be implemented by children
    def bind
    end
    
    # will be called on view attachment; ie after subviews are loaded
    def bind_deferred
    end
    
    def bound?
      return @bound
    end
    
  end
end
