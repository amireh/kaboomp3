module Pixy
  class IntroController < Controller
    
    protected
    
    def bind
      @app.connect(@app, SIGNAL('lastWindowClosed()'), @app, SLOT('quit()'))
    end
    
    def unbind
    end
    
  end
end