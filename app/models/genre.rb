require 'dm-core'

module Pixy
  
  class Genre
    include DataMapper::Resource
  
    storage_names[:default] = 'genres'
    
    has n, :albums
    
    property :id, Serial
    property :title, String, :length => 255, :required => true
    
  end
end
