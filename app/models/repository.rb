module Pixy
  class Repository < Model
    belongs_to :library
=begin
    include DataMapper::Resource
  
    storage_names[:default] = 'repositories'
    
    belongs_to :library
    
    property :id, Serial
    property :path, FilePath
=end    
  end
end
