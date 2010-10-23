module Pixy
  class LibraryController < Controller

    attr_writer :library
    
    slots 'update_sample_path()',
          'choose_library_path()',
          'save_preferences()'
    
    
    public
    
    def initialize(ui, path)
      super(ui, path)
      
      @library = Library.first
      
      # load our pages
      page_paths = { 
        :preferences  => File.join(path_to("views"), "library", "preferences.ui")
      }
      
      @pages = { }
      intro_view = @view.findChild(Qt::StackedWidget, "viewPreferences")
      page_paths.each_pair do |page_name, path|
        @pages[page_name] = load_view(path, intro_view, @ui[:loader])
        intro_view.addWidget(@pages[page_name])
      end
      
      
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
        }
      }
      
      @text_fields = {
        :library_path => @pages[:preferences].findChild(Qt::LineEdit, "libraryPath"),
        :sample_path  => @pages[:preferences].findChild(Qt::LineEdit, "samplePath")
      }
      
      @buttons = {
        :choosePath => @pages[:preferences].findChild(Qt::ToolButton, "chooseLibraryPath"),
        :update => @pages[:preferences].findChild(Qt::PushButton, "updatePreferences")
      }
      
      bind_pages
    end

    def attach
      super()
      
      force_defaults and populate
      update_sample_path
      
      switch_page(@pages[:preferences])
      
    end
    
    protected
    
    def force_defaults
      
      @radio_buttons[:storage][:soft_copy].checked = true
      @radio_buttons[:naming][:by_title].checked = true
      
    end
    
    def bind

    end
    
    def bind_pages

      @radio_buttons[:naming].each_pair do |key, button|
        connect(button, SIGNAL('toggled(bool)'), self, SLOT('update_sample_path()'))
      end
      
      @check_boxes[:sorting].each_pair do |key, box|
        connect(box, SIGNAL('toggled(bool)'), self, SLOT('update_sample_path()'))
      end
      
      connect(@buttons[:choosePath], SIGNAL('clicked()'), self, SLOT('choose_library_path()'))
      connect(@buttons[:update], SIGNAL('clicked()'), self, SLOT('save_preferences()'))
    end
    
    
    private
    
    def switch_page(page)
      @view.findChild(Qt::StackedWidget, "viewPreferences").setCurrentWidget(page)
    end
    
    def update_sample_path()
      path = ""
      path << "Library"
      # find out filename from radio button group :naming
      filename = ""
      @radio_buttons[:naming].each_pair { |key, button| filename = button.text and break if button.checked? }
      #@check_boxes[:sorting].each_pair { |key, box| path = File.join(path, "#{box.text}s") if box.checked? }
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
    
  end # class LibraryController
end # module Pixy