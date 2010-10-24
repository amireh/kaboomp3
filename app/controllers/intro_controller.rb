module Pixy
  class IntroController < Controller
    
    slots :quit, 
      :show_library_form, 
      :hide_library_form, 
      :create_library, 
      'show_library(QString)'


    def initialize(ui, path)
      super(ui, path)
  
      # get the 'canvas' element to which our children will attach
      # their pages 
      @views[:master].children.each do |element|
        @canvas = element and break if element.class == Qt::StackedWidget
      end
      
      @pages.merge!({
        :form => @canvas.findChild(Qt::Widget, "libraryForm"),
        :list => @canvas.findChild(Qt::Widget, "libraryList")
      })
      
      @buttons = { 
        :create_library => @canvas.findChild(Qt::PushButton, "createNewLibraryButton"),
        
      }
      
      @dialog_buttons = {
        :form => @views[:master].findChild(Qt::DialogButtonBox, "libraryFormButtonBox")
      }
      
      @frames = {
        :no_libraries => @canvas.findChild(Qt::Frame, "libraryNew"),
        :grid => @canvas.findChild(Qt::GroupBox, "libraryGrid")
      }
            
    end

    def attach
      super()
      
      if Library.find(:all).empty? then
        @frames[:no_libraries].show
      else
        switch_to(@pages[:list])
        list_libraries
      end
    end
   
    protected
    
    def bind  
    end
    
    def bind_deferred
      connect(
        @buttons[:create_library], 
        SIGNAL('clicked()'), 
        self, 
        SLOT('show_library_form()')
      )
      
      connect(
        @dialog_buttons[:form],
        SIGNAL('accepted()'),
        self, 
        SLOT('create_library()')
      )
      
      connect(
        @dialog_buttons[:form],
        SIGNAL('rejected()'), 
        self, 
        SLOT('hide_library_form()')
      )
      
    end
      
    private
    
    #########
    # SLOTS #
    #########
    def show_library_form
      switch_to(@pages[:form])
    end
    
    def hide_library_form
      switch_to(@pages[:list])
    end
    
    def create_library
      form = { :title => "", :emblem => "" }
      form[:title] = @pages[:form].findChild(Qt::LineEdit, "libraryTitleLineEdit").text
      
      if form[:title].empty?
        log "Error! Library title field is empty!!"
        return
      end
      
      library = Library.new(form)
      if library.save! then
        log "Library #{library.title} created"
      else
        log "There was a problem creating library with input: #{form.inspect}"
      end
      
      switch_to(@pages[:list])
    end
    
    def show_library(title)
      log "Switching to library #{title}"
      @ui[:controllers][:libraries].library = Library.find_by_title(title)
      transition(@ui[:controllers][:libraries])
    end
    
    def switch_to(page)
      @canvas.setCurrentWidget(page)
      page.show
    end
    
    def list_libraries
      libraries = Library.find(:all)
      
      @signal_mapper = Qt::SignalMapper.new(self)
      
      libraries.each do |library|
        list_library(library)
      end
      
      connect(@signal_mapper, SIGNAL('mapped(QString)'), self, SLOT('show_library(QString)'));
      
    end
    
    def list_library(library)
      
      libraryList = @canvas.findChild(Qt::Widget, "libraryList")
      layout = Qt::VBoxLayout.new()
      layout.sizeConstraint = Qt::Layout::SetMinAndMaxSize
      
      label = Qt::Label.new("#{library.title}", libraryList)
      label = Qt::Label.new(libraryList)
      label.objectName = "libraryTitle"
      sizePolicy = Qt::SizePolicy.new(Qt::SizePolicy::Preferred, Qt::SizePolicy::Maximum)
      sizePolicy.setHorizontalStretch(0)
      sizePolicy.setVerticalStretch(0)
      sizePolicy.heightForWidth = label.sizePolicy.hasHeightForWidth
      label.sizePolicy = sizePolicy
      label.alignment = Qt::AlignCenter
      label.text = library.title
      
      layout.addWidget(label)
      
      button = Qt::PushButton.new(libraryList)
      button.objectName = "pushButton"
      sizePolicy1 = Qt::SizePolicy.new(Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed)
      sizePolicy1.setHorizontalStretch(0)
      sizePolicy1.setVerticalStretch(0)
      sizePolicy1.heightForWidth = button.sizePolicy.hasHeightForWidth
      button.sizePolicy = sizePolicy1
      button.minimumSize = Qt::Size.new(120, 120)
      button.maximumSize = Qt::Size.new(120, 120)
      button.styleSheet = "QPushButton {\n" \
  "color: #ffffff;\n" \
  "font-weight: bold;\n" \
  "font-size: 14px;\n" \
  "	border-image: url(:/library_buttons/images/buttons/library/Silver.png);\n" \
  "}\n" \
  "QPushButton:pressed {\n" \
  "	border-image: url(:/library_buttons/images/buttons/library/Black.png);\n" \
  "}\n" \
  "QPushButton:disabled {\n" \
  "	border-image: url(:/120x120/images/buttons/round/120x120/Gray.png);\n" \
  "}"
  
      button.text = ""
      button.flat = true
    
      
      layout.addWidget(button)
      
      @signal_mapper.setMapping(button, "#{library.title}");
      connect(button, SIGNAL('clicked()'), @signal_mapper, SLOT('map()'))
               
      @frames[:grid].layout.addLayout(layout, 0, 0, 1, 1)
      
    end
    
  end # class IntroController
end # module Pixy