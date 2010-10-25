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
        :form => load_view(File.join(path_to("views"), "libraries", "new.ui"), @ui[:window], @ui[:loader]),
        :list => @canvas.findChild(Qt::Widget, "libraryList")
      })
      
      @buttons = { 
        :create_library => @canvas.findChild(Qt::PushButton, "createNewLibraryButton"),
        :add_library => @canvas.findChild(Qt::PushButton, "addLibraryButton")
      }
      
      @dialog_buttons = {
        :form => @pages[:form].findChild(Qt::DialogButtonBox, "libraryFormButtonBox")
      }
        
      @frames = {
        :no_libraries => @canvas.findChild(Qt::Frame, "libraryNew"),
        :grid => @canvas.findChild(Qt::GroupBox, "libraryGrid")
      }
      
      @labels = {
        :no_libraries => Qt::Label.new("Text", @frames[:grid])
      }
      
      @dialogs = {
        :too_many_libraries => Qt::MessageBox.new
      }
      
      @policies = {
        :size => {
          :grid => { 
            :labels => Qt::SizePolicy.new(Qt::SizePolicy::Preferred, Qt::SizePolicy::Maximum),
            :buttons => Qt::SizePolicy.new(Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed)
          }
          
        }
      }
      
      @dialogs[:too_many_libraries].text = "You cannot add any more libraries."
      @dialogs[:too_many_libraries].informativeText = "The maximum number of libraries allowed is 3."
      @dialogs[:too_many_libraries].windowTitle = "Notice"
      @dialogs[:too_many_libraries].icon = Qt::MessageBox.Information
      
      @labels[:no_libraries].sizePolicy = @policies[:size][:grid][:labels]
      @labels[:no_libraries].alignment = Qt::AlignCenter
      @labels[:no_libraries].text = "You have no libraries defined yet! Click the button below to add one."
      @labels[:no_libraries].hide
      
      @policies[:size][:grid].each_pair { |k, policy| policy.setHorizontalStretch(0); policy.setVerticalStretch(0) }
      
      
      @frames[:grid].layout.addWidget(@labels[:no_libraries])
      
      
      #@pages.each_pair { |key, page| page.hide }
    end

    def attach
      super()
      
      if Library.count == 0 then
        @labels[:no_libraries].show
      else
        switch_to(@pages[:list])
        update
        
        #list_libraries
        
      end
    end
   
    protected
    
    def bind  
    end
    
    def bind_deferred
      connect(@buttons[:add_library], SIGNAL('clicked()'), self, SLOT('show_library_form()'))
      connect(@dialog_buttons[:form], SIGNAL('accepted()'), self, SLOT('create_library()'))
      connect(@dialog_buttons[:form], SIGNAL('rejected()'), self, SLOT('hide_library_form()'))
    end
      
    private
    
    #########
    # SLOTS #
    #########
    def show_library_form
      if Library.count >= 3 then
        @dialogs[:too_many_libraries].show
        return
      end
      
      @pages[:form].show
      #switch_to(@pages[:form])
    end
    
    def hide_library_form
      @pages[:form].hide
      #switch_to(@pages[:list])
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
      
      update
      #switch_to(@pages[:list])
    end
    
    def show_library(title)
      
      @ui[:controllers][:libraries].library = Library.find_by_title(title)
      log "Switching to library #{@ui[:controllers][:libraries].library.title}"
      transition(@ui[:controllers][:libraries])
      
    end
    
    def switch_to(page)
      @canvas.setCurrentWidget(page)
      page.show
    end
    
    def clear_view
      @frames[:grid].children.each do |element|
        unless element.class == Qt::GridLayout
          @frames[:grid].layout.removeWidget(element)
          element.dispose
        end
      end      
    end
    
    def update
      clear_view
      list_libraries
    end
    
    def list_libraries
      libraries = Library.find(:all, :order => "created_at ASC")
      
      @signal_mapper = Qt::SignalMapper.new(self)
      
      index = 1
      libraries.each do |library|
        add_library_to_grid(library,index)
        index += 1
      end
      
      connect(@signal_mapper, SIGNAL('mapped(QString)'), self, SLOT('show_library(QString)'));
      
    end
    
    def add_library_to_grid(library, index)
      
      entry = { 
        :layout => nil, 
        :label => nil, 
        :button => nil
      }
      
      entry[:layout] = Qt::VBoxLayout.new()
      entry[:layout].sizeConstraint = Qt::Layout::SetMinAndMaxSize
      entry[:layout].objectName = "libraryLayout#{index}"
      
      entry[:label] = create_grid_label(library.title, index)
      
      entry[:button] = create_grid_button(index)
      
      # add label and button to our vertical layout
      entry[:layout].addWidget(entry[:label])
      entry[:layout].addWidget(entry[:button])
      # add the vertical layout to the grid (grid contains 3 items in each row)
      @frames[:grid].layout.addLayout(
        entry[:layout], 
        ((index-1)/3).to_i, # row
        index % 3, # column
        1, 1) # rowspan & colspan
      
      # bind the button
      @signal_mapper.setMapping(entry[:button], "#{library.title}");
      connect(entry[:button], SIGNAL('clicked()'), @signal_mapper, SLOT('map()'))
      
    end
    
    # helpers
    def create_grid_label(text, id)
      label = Qt::Label.new("#{text}", @frames[:grid])
      label.objectName = "libraryTitle#{id}"
      label.sizePolicy = @policies[:size][:grid][:labels]
      label.alignment = Qt::AlignCenter
      label.textFormat = Qt::RichText
      label.focusPolicy = Qt::NoFocus
      
      label
    end
    
    def create_grid_button(id)
      button = Qt::PushButton.new(@frames[:grid])
      button.objectName = "libraryButton#{id}"
      button.sizePolicy = @policies[:size][:grid][:buttons]
      button.minimumSize = Qt::Size.new(120, 120)
      button.maximumSize = Qt::Size.new(120, 120)
      button.styleSheet = "QPushButton {\n" \
        "color: #ffffff;\n" \
        "font-weight: bold;\n" \
        "font-size: 14px;\n" \
        "	border-image: url(:/library_buttons/images/buttons/library/Black2.png);\n" \
        "}\n" \
        "QPushButton:hover {\n" \
        " border-image: url(:/library_buttons/images/buttons/library/Silver2.png);\n" \
        "}\n" \
        "QPushButton:pressed {\n" \
        " border-image: url(:/library_buttons/images/buttons/library/Red.png);\n" \
        "}"
  
      button.text = ""
      button.flat = true
      button.focusPolicy = Qt::NoFocus
      
      button
    end
    
  end # class IntroController
end # module Pixy