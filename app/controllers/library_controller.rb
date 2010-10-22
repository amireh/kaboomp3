module Pixy
  class LibraryController < Controller

    slots :back_to_libraries
      
    protected
    
    def bind
      @ui[:qt].connect(
        @view.findChild(Qt::PushButton, "button_backToLibraries"),
        SIGNAL('clicked()'),
        self,
        SLOT('back_to_libraries()')
      )
    end
    
    private
    
    def back_to_libraries
      transition(@ui[:controllers][:intro])
    end
    
  end # class LibraryController
end # module Pixy