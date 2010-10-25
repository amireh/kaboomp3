module Pixy
  class InvalidArgument < Exception; end
  class InvalidState < Exception; end
  class InvalidTransition < Exception; end
  class InvalidView < Exception; end
  class InvalidFile < Exception; end
	class InvalidPath < Exception; end
	class InvalidLibrary < Exception; end
	
	class PreviewFailed < RuntimeError
	  attr_accessor :repairable
	  
	  def initialize(repairable = false)
	    @repairable = repairable
    end
    
  end
  
end
