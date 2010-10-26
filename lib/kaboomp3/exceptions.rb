module Pixy
  class InvalidArgument < Exception; end
  class InvalidState < Exception; end
  class InvalidTransition < Exception; end
  class InvalidView < Exception; end
  class InvalidFile < Exception; end
	class DestinationExists < Exception; end
	
	class InvalidLibrary < Exception
	  attr_reader :empty_library, :invalid_path
	  
	  def initialize(cause)
	    super()
	    
	    @empty_library = true if cause == Library::EmptyLibrary
	    @invalid_path = true if cause == Library::InvalidPath
    end
    
    def empty_library?
      @empty_library
    end
    
    def invalid_path?
      @invalid_path
    end

  end
  
	class PreviewFailed < RuntimeError
  end
  
end
