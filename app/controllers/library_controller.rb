module Pixy
  class LibraryController < Controller

    attr_accessor :library
    attr_reader :state
    
    slots 'update_sample_path()',
          'choose_library_path()',
          'save_preferences()',
          'back_to_libraries()',
          'switch_page(int)',
          'user_agreement()',
          'do_organize()'

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
        :organize => @pages[:actions][:preview].findChild(Qt::PushButton, "organize"),
        :back_to_libraries => @views[:master].findChild(Qt::PushButton, "backToLibraries")
      }
      
      @tree = @pages[:preview].findChild(Qt::TreeView, "treeView")
      
      @state = "customizing"
    end

    def attach
      super()
      
      raise InvalidState if @library.nil?
      
      force_defaults
      populate
      
      update
        
    end
    
    protected
    
    def force_defaults
      
      @radio_buttons[:storage][:soft_copy].checked = true
      @radio_buttons[:naming][:by_title].checked = true
      @buttons[:organize].enabled = false
      
      @canvas.setCurrentWidget(@tabs[:preferences])
      @views[:actions].setCurrentWidget(@pages[:actions][:preferences])
    end
    
    def bind
      
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
      connect(@buttons[:organize], SIGNAL('clicked()'), self, SLOT('do_organize()'))
      connect(@buttons[:back_to_libraries], SIGNAL('clicked()'), self, SLOT('back_to_libraries()'))
      
      connect(@canvas, SIGNAL('currentChanged(int)'), self, SLOT('switch_page(int)'))
    end
    
    
    private
    
    def update
      
      if @state == "customizing"
        update_sample_path
      end
      
      if @state == "previewing"
        simulated_library = simulate()
        
        fsm = Qt::FileSystemModel.new
        fsm.readOnly = true
        fsm.resolveSymlinks = false
        fsm.rootPath = @library.path
        @tree.model = fsm
        @tree.rootIndex = fsm.index(simulated_library)
        @tree.header.hideSection(1)
        @tree.header.hideSection(2)
        @tree.header.hideSection(3)
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
                                  Qt::Dir.currentPath(), 
                                  Qt::FileDialog::DontResolveSymlinks |
                                  Qt::FileDialog::ShowDirsOnly)
      if !directory.nil?
          @text_fields[:library_path].text = directory
      end
    end
    
    def save_preferences()
      
      naming = ""
      @radio_buttons[:naming].each_pair { |key, button| naming = button.text and break if button.checked? }
      
      @library.update_attributes(
        :path => @text_fields[:library_path].text,
        :sort_by_genre => @check_boxes[:sorting][:by_genre].checked?,
        :sort_by_artist => @check_boxes[:sorting][:by_artist].checked?,
        :sort_by_album => @check_boxes[:sorting][:by_album].checked?,
        :naming => naming,
        :hard_copy => @radio_buttons[:storage][:hard_copy].checked?
      )
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
      @radio_buttons[:naming][:by_title].checked = true if @library.naming == "Track Title.mp3"
      @radio_buttons[:naming][:by_artist].checked = true if @library.naming == "Artist - Track Title.mp3"
      @radio_buttons[:naming][:by_album].checked = true if @library.naming == "Album - Track Title.mp3"
      
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
    
    def simulate
      temp = File.join(ENV['APP_ROOT'], "tmp", "snapshot_#{Time.now.to_i}")
      FileUtils.mkdir_p(temp)
      
      if !File.exists?(temp)
        log "Could not create temp library!"
        return
      end
      
      Pandemonium.instance.organizer.simulate(library, temp)
      
      return temp
    end
    
  end # class LibraryController
end # module Pixy