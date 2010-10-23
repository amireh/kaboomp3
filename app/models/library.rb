# The Library maintains a list of all its Tracks and
# has some preferences the user could customize.
# Libraries are populated with the tracks by the "Inspector"

module Pixy
  class Library < ActiveRecord::Base
    has_many :repositories
    has_many :tracks
=begin
    include DataMapper::Resource
  
    storage_names[:default] = 'libraries'

    has n, :repositories
    has n, :tracks
    
    property :id, Serial
    property :title, String, :length => 255, :default => "Untitled Library"
    property :emblem, String, :required => false
    
    property :created_at, DateTime
    property :created_on, Date
=end
  end
end
