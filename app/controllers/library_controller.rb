module Pixy
  class LibraryController < Controller

    attr_accessor :library
    attr_reader :state, :preview_stats
    
    
    slots 'update_sample_path()',
          'choose_library_path()',
          'save_preferences()',
          'back_to_libraries()',
          'switch_page(int)',
          'user_agreement()',
          'do_organize()',
          'do_preview()',
          'remove_library()',
          'do_remove_library()'

    public
    
    def initialize(ui, path)
      super(ui, path)
      
      @canvas = @views[:master].findChild(Qt::TabWidget, "viewLibrary")

      @pages.merge!({ :actions => { } })
      @views.merge!({
        :preferences => @views[:master].findChild(Qt::StackedWidget, "viewPreferences"),
        :preview => @views[:master].findChild(Qt::StackedWidget, "viewPreview"),
        :actions => @views[:master].findChild(Qt::StackedWidget, "viewActions")
      })
            
      # load our pages
      paths = { 
        :pages => {
          :preferences => File.join(path_to("views"), "libraries", "_preferences.ui"),
          :preview => File.join(path_to("views"), "libraries", "_preview.ui")        
        },
        :actions => {
          :preferences => File.join(path_to("views"), "libraries", "_preferences_actions.ui"),
          :preview => File.join(path_to("views"), "libraries", "_preview_actions.ui")          
        }
      }
      
      # populate pages and load them
      paths[:pages].each_pair do |page, path|

        @pages[page] = load_view(path, @views[page], @ui[:loader])
        @views[page].addWidget(@pages[page])
        
        #puts "added #{@pages[page].objectName} to #{@views[page].objectName}"
      end
      
      # populate action pages and load them
      paths[:actions].each_pair do |page, path|
        @pages[:actions][page] = load_view(path, @views[page], @ui[:loader])
        @views[:actions].addWidget(@pages[:actions][page])
        #puts "loaded action view: #{page} => #{@pages[:actions][page].inspect}"
      end
      
      @tabs = {
        :preview => @canvas.findChild(Qt::Widget, "tabPreview"),
        :preferences => @canvas.findChild(Qt::Widget, "tabPreferences")
      }
      
      @radio_buttons = {
        :naming => {
          :by_title   => @pages[:preferences].findChild(Qt::RadioButton, "nameByTitle"),
          :by_artist  => @pages[:preferences].findChild(Qt::RadioButton, "nameByArtist"),
          :by_album   => @pages[:preferences].findChild(Qt::RadioButton, "nameByAlbum")
        },
        :storage => {
          :hard_copy => @pages[:preferences].findChild(Qt::RadioButton, "hardCopy"),
          :soft_copy => @pages[:preferences].findChild(Qt::RadioButton, "softCopy")
        }
      }
      
      @check_boxes = {
        :sorting => {
          :by_genre   => @pages[:preferences].findChild(Qt::CheckBox, "sortByGenre"),
          :by_artist  => @pages[:preferences].findChild(Qt::CheckBox, "sortByArtist"),
          :by_album   => @pages[:preferences].findChild(Qt::CheckBox, "sortByAlbum")
        },
        :changes_confirmed => @pages[:preview].findChild(Qt::CheckBox, "changesConfirmed")
      }
      
      @text_fields = {
        :library_path => @pages[:preferences].findChild(Qt::LineEdit, "libraryPath"),
        :sample_path  => @pages[:preferences].findChild(Qt::LineEdit, "samplePath")
      }
          
      @buttons = {
        :choosePath => @pages[:preferences].findChild(Qt::ToolButton, "chooseLibraryPath"),
        :update => @pages[:actions][:preferences].findChild(Qt::PushButton, "updatePreferences"),
        :remove => @pages[:actions][:preferences].findChild(Qt::PushButton, "removeLibrary"),
        :preview => @pages[:actions][:preview].findChild(Qt::PushButton, "preview"),
        :organize => @pages[:actions][:preview].findChild(Qt::PushButton, "organize"),
        :back_to_libraries => @views[:master].findChild(Qt::PushButton, "backToLibraries")
      }
      
      @pbars = {
        :preview => @pages[:preview].findChild(Qt::ProgressBar, "progressBar")
      }
      
      @dialogs = {
        :remove_library => Qt::MessageBox.new,
        :preview_failed => Qt::MessageBox.new,
        :retry_preview => Qt::MessageBox.new
      }
      
      @dialogs[:remove_library].text = "Are you sure you want to remove this library?"
      @dialogs[:remove_library].informativeText = "This action is not reversible."
      @dialogs[:remove_library].windowTitle = "Removing library"
      @dialogs[:remove_library].icon = Qt::MessageBox::Warning
      @dialogs[:remove_library].addButton(Qt::MessageBox::Yes)
      @dialogs[:remove_library].addButton(Qt::MessageBox::No)
      @dialogs[:remove_library].defaultButton = @dialogs[:remove_library].buttons.last

      @dialogs[:preview_failed].text = "Sorry! Preview failed."
      @dialogs[:preview_failed].informativeText = "" \
      "There was an error simulating your sorted library. " \
      "If this problem persists, please contact us by visitng our website: " \
      "http://kaboom.amireh.net."
      @dialogs[:preview_failed].windowTitle = "Preview Failed"
      @dialogs[:preview_failed].icon = Qt::MessageBox::Critical
      @dialogs[:preview_failed].addButton(Qt::MessageBox::Ok)
      @dialogs[:preview_failed].defaultButton = @dialogs[:preview_failed].buttons.first
            
      @dialogs[:retry_preview].text = "Sorry! Preview failed."

      @dialogs[:retry_preview].windowTitle = "Preview Failed"
      @dialogs[:retry_preview].icon = Qt::MessageBox::Warning
      @dialogs[:retry_preview].addButton(Qt::MessageBox::Ok)
      @dialogs[:retry_preview].defaultButton = @dialogs[:preview_failed].buttons.first

      
      @tree = @pages[:preview].findChild(Qt::TreeView, "treeView")
      
      @fsm = Qt::FileSystemModel.new
      @fsm.readOnly = true
      @fsm.resolveSymlinks = false
      
      @state = "customizing"
    end

    def attach
      super()
      
      raise InvalidState if @library.nil?
      
      force_defaults
      populate
      
      update
    end
    
    def update_progress(stepper, step)
      @pbars[:preview].value = (stepper / step)
      @ui[:qt].processEvents
    end
    
    protected
    
    def force_defaults
      
      @radio_buttons[:storage][:soft_copy].checked = true
      @radio_buttons[:naming][:by_title].checked = true
      @buttons[:organize].enabled = false
      
      @canvas.setCurrentWidget(@tabs[:preferences])
      @views[:actions].setCurrentWidget(@pages[:actions][:preferences])
    end
    
    
    def bind_deferred

      @radio_buttons[:naming].each_pair do |key, button|
        connect(button, SIGNAL('toggled(bool)'), self, SLOT('update_sample_path()'))
      end
      
      @check_boxes[:sorting].each_pair do |key, box|
        connect(box, SIGNAL('toggled(bool)'), self, SLOT('update_sample_path()'))
      end
      
      connect(@check_boxes[:changes_confirmed], SIGNAL('toggled(bool)'), self, SLOT('user_agreement()'))
      
      connect(@buttons[:choosePath], SIGNAL('clicked()'), self, SLOT('choose_library_path()'))
      connect(@buttons[:update], SIGNAL('clicked()'), self, SLOT('save_preferences()'))
      connect(@buttons[:remove], SIGNAL('clicked()'), self, SLOT('remove_library()'))
      connect(@buttons[:organize], SIGNAL('clicked()'), self, SLOT('do_organize()'))
      connect(@buttons[:preview], SIGNAL('clicked()'), self, SLOT('do_preview()'))
      connect(@buttons[:back_to_libraries], SIGNAL('clicked()'), self, SLOT('back_to_libraries()'))
      
      connect(@dialogs[:remove_library].buttons.first, SIGNAL('clicked()'), self, SLOT('do_remove_library()'))
      #connect(@dialogs[:retry_preview].buttons.first, SIGNAL('clicked()'), self, SLOT('do_remove_library()'))
      #connect(@dialogs[:preview_failed].buttons.first, SIGNAL('clicked()'), self, SLOT('do_remove_library()'))
      
      connect(@canvas, SIGNAL('currentChanged(int)'), self, SLOT('switch_page(int)'))
      
      @bound = true
    end
    
    
    private
    
    def update
      
      if @state == "customizing"
        update_sample_path
      end
      
      if @state == "previewing"
        #simulated_library = simulate()
      end
      
    end
    
    def switch_page(page_id)
      raise InvalidArgument unless page_id.is_a?(Integer)
      
      # get the actual page widget using the index page_id
      page = @canvas.widget(page_id)

      raise InvalidState if page.nil?
      
      @state = "previewing" if @canvas.currentWidget.objectName == @tabs[:preview].objectName
      @state = "customizing" if @canvas.currentWidget.objectName == @tabs[:preferences].objectName
            
      page_name = page_name_from_id(page_id)
      @views[:actions].setCurrentWidget(@pages[:actions][page_name.to_sym])
      
      update
    end
    
    # gets our local identifier of in_page from the actual widget
    def page_name_from_id(page_id)
      case page_id
      when @canvas.indexOf(@canvas.findChild(Qt::Widget, "tabPreferences"))
        "preferences"
      when @canvas.indexOf(@canvas.findChild(Qt::Widget, "tabPreview"))
        "preview"
      end
    end
    
    def update_sample_path()
      path = ""
      path << "Library"
      # find out filename from radio button group :naming
      filename = ""
      @radio_buttons[:naming].each_pair { |key, button| filename = button.text and break if button.checked? }
      path = File.join(path, "Genre") if @check_boxes[:sorting][:by_genre].checked?
      path = File.join(path, "Artist") if @check_boxes[:sorting][:by_artist].checked?
      path = File.join(path, "Album") if @check_boxes[:sorting][:by_album].checked?
      path = File.join(path, filename)
      
      @text_fields[:sample_path].text = path
    end
    
    def choose_library_path()
      directory = Qt::FileDialog.getExistingDirectory(@ui[:window], 
                                  "Find Files", 
                                  @library.path || Qt::Dir.currentPath(), 
                                  Qt::FileDialog::DontResolveSymlinks |
                                  Qt::FileDialog::ShowDirsOnly)
      if !directory.nil?
          @text_fields[:library_path].text = directory
      end
    end
    
    def save_preferences()
      
      naming = ""
      @radio_buttons[:naming].each_pair { |key, button| naming = button.text and break if button.checked? }
      naming = case naming
      when "Track Title.mp3"
        Library::ByTitle
      when "Artist - Track Title.mp3"
        Library::ByArtistAndTitle
      when "Album - Track Title.mp3"
        Library::ByAlbumAndTitle
      end
      
      @library.update_attributes(
        :path => @text_fields[:library_path].text,
        :sort_by_genre => @check_boxes[:sorting][:by_genre].checked?,
        :sort_by_artist => @check_boxes[:sorting][:by_artist].checked?,
        :sort_by_album => @check_boxes[:sorting][:by_album].checked?,
        :naming => naming,
        :hard_copy => @radio_buttons[:storage][:hard_copy].checked?
      )
      
    end
    
    def remove_library()
      @dialogs[:remove_library].show
    end
    
    def do_remove_library()
      @library.destroy
      back_to_libraries
    end
    
    def back_to_libraries()
      transition(@ui[:controllers][:intro])
    end
    
    def populate()
      @text_fields[:library_path].text = @library.path
      
      # sorting checkboxes
      @check_boxes[:sorting][:by_genre].checked = true if @library.sort_by_genre?
      @check_boxes[:sorting][:by_artist].checked = true if @library.sort_by_artist?
      @check_boxes[:sorting][:by_album].checked = true if @library.sort_by_album?
      
      # naming radio button
      @radio_buttons[:naming][:by_title].checked = true if @library.naming == Library::ByTitle
      @radio_buttons[:naming][:by_artist].checked = true if @library.naming == Library::ByArtistAndTitle
      @radio_buttons[:naming][:by_album].checked = true if @library.naming == Library::ByAlbumAndTitle
      
      @radio_buttons[:storage][:soft_copy].checked = true if !@library.hard_copy?
      @radio_buttons[:storage][:hard_copy].checked = true if @library.hard_copy?
    end
    
    def user_agreement
      if @check_boxes[:changes_confirmed].checked? then
        @buttons[:organize].enabled = true
      else
        @buttons[:organize].enabled = false
      end
    end
    
    def do_preview
      begin
        temp = File.join(ENV['APP_ROOT'], "tmp", "snapshot_#{Time.now.to_i}")
        FileUtils.mkdir_p(temp)
      
        if !File.exists?(temp) || !File.writable?(temp)
          @dialogs[:retry_preview].informativeText = "" \
          "Please make sure you that have write privileges to " \
          "the directory in which kaBoom resides, and try again. "          
          raise PreviewFailed.new(true), "destination does not exist or is not writable!"
        end
      
  			failed = false
  			@pbars[:preview].value = 0
  			
  			begin
  	      @preview_stats = KaBoom.instance.organizer.simulate(library, temp)
  			rescue InvalidPath => e
          @dialogs[:retry_preview].informativeText = "" \
          "Please make sure you have chosen a valid library path " \
          "to organize, and try again."
  				raise PreviewFailed.new(true), "library path possibly nil? #{e.message}"
  			end
  			
  	  rescue PreviewFailed => e
	      @dialogs[:retry_preview].show
  	    @pbars[:preview].value = 100	      
	      return
      rescue Exception => e
  		  @dialogs[:preview_failed].show
  	    @pbars[:preview].value = 100  		  
  	    log e.message
  	    return
      end
      

      @fsm.rootPath = temp
      @tree.model = @fsm
      @tree.rootIndex = @fsm.index(temp)
      @tree.header.hideSection(1)
      @tree.header.hideSection(2)
      @tree.header.hideSection(3)
      @tree.expandAll
      
      @pbars[:preview].value = 100
      puts @preview_stats.inspect
      #return temp
    end
    
  end # class LibraryController
end # module Pixy
