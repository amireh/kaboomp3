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
      
      patch_ui
    end
    
    def attach
      super()
      
      update
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
    
    def update
      #clear_view
      scrollArea = @view.findChild(Qt::ScrollArea, "scrollArea")
      scrollArea.widgetResizable=true
      
      layout = @view.findChild(Qt::FormLayout, "layoutLibraries").parent
      layout.setParent(nil)
      scrollArea.setWidget(layout)
      scrollArea.ensureWidgetVisible(layout)
      
      layout.children.each do |widget|
        widget.dispose unless widget.class == Qt::FormLayout
      end
      
      # recreate our library list
      widgets = { :button => nil, :text => nil }
      size_policies = { 
        :min_expanding => Qt::SizePolicy.new(Qt::SizePolicy::MinimumExpanding, Qt::SizePolicy::MinimumExpanding),
        :preferred => Qt::SizePolicy.new(Qt::SizePolicy::Preferred, Qt::SizePolicy::Preferred)
      }
      
      @libraries = Library.find(:all).each do |library|
        widgets[:button] = Qt::PushButton.new(layout)
        widgets[:button].objectName = "buttonGoToLibrary_#{library.id}"
        widgets[:button].text = Qt::Application.translate("Form", library.title, nil, Qt::Application::UnicodeUTF8)
        widgets[:button].sizePolicy = size_policies[:min_expanding]
        widgets[:button].minimumSize = Qt::Size.new(80, 80)
        widgets[:button].maximumSize = Qt::Size.new(80, 80)
        
        widgets[:text] = Qt::TextBrowser.new(layout)
        widgets[:text].objectName = "textBrowserLibrary_#{library.id}"
        widgets[:text].frameShape = Qt::Frame::StyledPanel
        
        layout.findChild(Qt::FormLayout, "layoutLibraries").addRow(widgets[:button], widgets[:text])
        #widgets[:button].show
        #widgets[:text].show
      end
      
      #scrollArea.findChild(Qt::Widget, "scrollAreaWidgetContents").resize(Qt::Size.new(400, 1000))
      #puts "Layout => #{layout.inspect}"
      #puts "----"
      #puts "Layout children =>: #{layout.children.inspect}"
    end

    def patch_ui
      
    end
    
    private
    
    def show_create_library
      @overlays[:create_library].show
    end
    
    def create_library
      form = { :title => "", :emblem => "" }
      form[:title] = @overlays[:create_library].findChild(Qt::LineEdit, "libraryTitleLineEdit").text
      
      log "Error! Library title field is empty!!" and return if form[:title].empty?
      
      library = Library.new(form)
      if library.save! then
        log "Library #{library.title} created"
      else
        log "There was a problem creating library with input: #{form.inspect}"
      end
      
      update
    end
    
    def cancel_create_library
      log "cancelled !"
    end
    
    def goto_library
      transition(@ui[:controllers][:library])
    end
    
        
  end # class IntroController
end # module Pixy

