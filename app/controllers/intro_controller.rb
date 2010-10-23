module Pixy
  class IntroController < Controller
    
    slots :quit, :show_library_form, :create_library, :cancel_create_library, :goto_library

    def initialize(ui, path)
      super(ui, path)
      
      
      # load our pages
      page_paths = { 
        :library_add  => File.join(path_to("views"), "intro", "library_add.ui"), 
        :library_form => File.join(path_to("views"), "intro", "library_form.ui"),
        :library_list => File.join(path_to("views"), "intro", "library_list.ui")
      }
      
      @pages = { }
      intro_view = @view.findChild(Qt::StackedWidget, "introView")
      page_paths.each_pair do |page_name, path|
        @pages[page_name] = load_view(path, intro_view, @ui[:loader])
        intro_view.addWidget(@pages[page_name])
      end
      
      # load our overlays
      #overlay_path = File.join(path_to("overlays"), "create_library.ui")
      #@overlays[:create_library] = load_view(overlay_path, @ui[:window], @ui[:loader])
      
      # and bind their event handlers
      bind_pages
      

      
      #intro_view.setCurrentWidget(@pages[:library_add])
    end
    
    def attach
      super()
      
      if Library.find(:all).empty? then
        switch_page(@pages[:library_add])
      else
        @ui[:controllers][:library].library = Library.first
        transition(@ui[:controllers][:library])
        #list_library(Library.first)
      end
    end
    
    protected
    
    def bind
          
    end
    
    def bind_pages
      connect(
        @pages[:library_add].findChild(Qt::PushButton, "button_createLibrary"), 
        SIGNAL('clicked()'), 
        self, 
        SLOT('show_library_form()')
      )
      
      connect(
        @pages[:library_form], 
        SIGNAL('accepted()'), 
        self, 
        SLOT('create_library()')
      )
      
      connect(
        @pages[:library_form], 
        SIGNAL('rejected()'), 
        self, 
        SLOT('cancel_create_library()')
      )
    end
    
    def update
=begin
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
=end
    end

    
    private
    
    def show_library_form
      switch_page(@pages[:library_form])
    end
    
    def create_library
      form = { :title => "", :emblem => "" }
      form[:title] = @pages[:library_form].findChild(Qt::LineEdit, "text_libraryTitle").text
      
      log "Error! Library title field is empty!!" and return if form[:title].empty?
      
      library = Library.new(form)
      if library.save! then
        log "Library #{library.title} created"
      else
        log "There was a problem creating library with input: #{form.inspect}"
      end
      
      list_library(library)
    end
    
    def cancel_create_library
      log "cancelled !"
      switch_page(@pages[:library_add])
    end
    
    def goto_library
      transition(@ui[:controllers][:library])
    end
    
    def switch_page(page)
      @view.findChild(Qt::StackedWidget, "introView").setCurrentWidget(page)
    end
    
    def list_library(library)
      @pages[:library_list].findChild(Qt::Label, "label_libraryTitle").text = library.title
      #@pages[:library_list].findChild(Qt::Label, "text_libraryInfo").text = "Stuff here"
      
      switch_page(@pages[:library_list])
      
      
    end
    
  end # class IntroController
end # module Pixy