module Pixy
  module Utility
    @@init = false
    @@logger = nil
  
    def log(msg, options = {})
      if !@@init then
        @@log_path = File.join(ENV['APP_ROOT'], 'log')
				if !File.exists?(@@log_path) then FileUtils.mkdir_p(@@log_path) end
        #@@logger = File.open((File.join(@@log_path, "debug.log")), "w+")
        @@logger = STDOUT
        #@@logger = File.open()
      	@@logger.write("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n")
      	@@logger.write("+                               kaBoom                              +\n")
      	@@logger.write("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n")
      	@@logger.flush
      	@@init = true
      end
    
      #level = options.has_key?(:level) ? options[:level] : "INFO"
      #options[:level] ||= "INFO"
      
      @@logger.write( "+ #{msg}\n" )
      @@logger.flush
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
    
    def cleanup_empty_dirs(root)
      # cleanup now-empty directories
      log "cleaning up empty directories"
      recursive_rmdir(root)
      #Dir.glob("#{root}/*").each do |file|
      #  if File.directory? file then
      #    empty = true
      #    Dir.glob("#{file}/**/*").each do |subfile|
      #      unless File.directory? subfile then
      #        empty = false
      #        break
      #      end
      #    end
      #  
      #    if empty
      #      puts "deleting #{file}"
      #      FileUtils.rm_r(file)
      #    end
      #  
      #  end
      #        
      #end
      
      #2.times do
      #  Dir.glob("#{path}/**/*").each { |entry| 
      #  if File.directory?(entry) && (Dir.entries(entry) - %w[. ..]).empty?
      #    log "\tremoving directory: #{entry}"
      #    FileUtils.rmdir(entry)
      #  end
      #  }
      #end
    end
    
    def recursive_rmdir(dir)

      # find my children directories
      Dir.glob("#{dir}/*").each { |file| recursive_rmdir(file) if File.directory? file }

      # am I empty?
      if Dir.glob("#{dir}/*").empty?
        log "\tremoving empty directory #{dir}"
        # delete me
        FileUtils.rmdir(dir) rescue nil
      end

    end

  end # module Utility
end # module Pixy
