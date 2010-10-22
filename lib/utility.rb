module Pixy

  class InvalidView < Exception; end
  
  module Utility
    @@init = false
    @@log_path = File.join(ENV['APP_ROOT'], 'log')
    @@logger = nil
  
    def log(msg, options = {})
      if !@@init then
        #@@logger = File.open((File.join(@@log_path, "debug.log")), "w+")
        @@logger = File.open(0)
      	@@logger.write("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n")
      	@@logger.write("+                           Pandemonium                             +\n")
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
  end
  
end

#Pixy.quickfix