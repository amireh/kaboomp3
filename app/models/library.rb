# The Library maintains a list of all its Tracks and
# has some preferences the user could customize.
# Libraries are populated with the tracks by the "Inspector"

module Pixy
  class Library < ActiveRecord::Base
    has_many :repositories
    has_many :tracks
    
    ByTitle=0
    ByArtistAndTitle=1
    ByAlbumAndTitle=2
    
    # invalid states
    InvalidPath = 100
    EmptyLibrary = 101
    
  end
end
