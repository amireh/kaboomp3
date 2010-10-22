# Encapsulates a music track; a track has a title, an album, an artist,
# a genre, a codec (only MP3 is supported for now), and a unique signature (null as of this writing)
# tracks belong to a library, and they have an important duty of maintaining 
# their manipulation history; say when a track is "organized", its earlier state
# is kept track of here for later rollbacks if needed

module Pixy
  class Track < Model
    belongs_to :album
    belongs_to :library
=begin
    include DataMapper::Resource
  
    storage_names[:default] = 'tracks'
    
    belongs_to :album
    belongs_to :library
    
    property :id, Serial
    property :title, String, :length => 255, :default => "Untitled"
    property :codec, String, :default => "mp3"
    property :signature, String

    property :created_at, DateTime
    property :created_on, Date
=end
  end
end
