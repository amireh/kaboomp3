require 'dm-core'
require 'dm-timestamps'

module Pixy
  
  class Artist
    include DataMapper::Resource
  
    storage_names[:default] = 'artists'
    
    has n, :albums
    has n, :tracks, :through => :albums
    
    property :id, Serial
    property :name, String, :length => 255, :default => "Unknown Artist"
    
    property :created_at, DateTime
    property :created_on, Date
    
  end
end
