module Pixy

  class InvalidView < Exception; end

  module Utility
    @@init = false
    @@log_path = File.join(ENV['APP_ROOT'], 'log')
    @@logger = nil
  
    def log(msg, options = {})
      if !@@init then
        @@logger = File.open((File.join(@@log_path, "debug.log")), "w+")
        #@@logger = File.open()
      	@@logger.write("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n")
      	@@logger.write("+                           Pandemonium                             +\n")
      	@@logger.write("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n")
      	@@logger.flush
      	@@init = true
      end
    
      #level = options.has_key?(:level) ? options[:level] : "INFO"
      #options[:level] ||= "INFO"
      
      #@@logger.write( "+ #{msg}\n" )
      #@@logger.flush
      puts "+ #{msg}"
    end
  
    # returns whether filename matches %STRING%.rb
    def ruby_script?(filename)
      (filename =~ /\A[^\.].(.)*.(\.rb)\z/) != nil
    end
    
    def path_to(resource)
      case resource
        when "controllers" then File.join(ENV['APP_ROOT'], "app", "controllers")
        when "models" then File.join(ENV['APP_ROOT'], "app", "models")
        when "views" then File.join(ENV['APP_ROOT'], "app", "views")
        when "overlays" then File.join(ENV['APP_ROOT'], "app", "views", "overlays")
        when "tasks" then File.join(ENV['APP_ROOT'], "lib", "tasks")
        when "logs" then File.join(ENV['APP_ROOT'], "log")
        when "migrations" then File.join(ENV['APP_ROOT'], "data", "migrations")
      end
    end
    
    # ----
    # helper method to load a Qt UI view
    # requires path to the .ui file, parent widget, and a handle to a Qt::UiLoader instance
    #
    def load_view(path, parent, loader)
      sheet = Qt::File.new(path)
      sheet.open(Qt::File::ReadOnly)
      view = loader.load(sheet, parent)
      sheet.close
      
      view
    end
    
  end # module Utility
end # module Pixy