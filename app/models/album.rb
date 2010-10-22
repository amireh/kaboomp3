module Pixy
  class Album < Model
    include DataMapper::Resource
  
    storage_names[:default] = 'albums'
    
    belongs_to :artist
    belongs_to :genre
    has n, :tracks
    
    property :id, Serial
    property :title, String, :length => 255, :default => "Untitled Album"
    property :publisher, String
    property :publish_year, Integer
    
    property :created_at, DateTime
    property :created_on, Date
  end
end
