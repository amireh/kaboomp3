# Encapsulates a music track; a track has a title, an album, an artist,
# a genre, a codec (only MP3 is supported for now), and a unique signature (null as of this writing)
# tracks belong to a library, and they have an important duty of maintaining 
# their manipulation history; say when a track is "organized", its earlier state
# is kept track of here for later rollbacks if needed

module Pixy
  class Track < ActiveRecord::Base
		include Pixy::Utility
    belongs_to :album
    belongs_to :library

    attr_reader :title, :album, :artist, :genre, :filepath
    
    @@defaults = { 
      :title => "Untitled Track",
      :artist => "Unknown Artist",
      :album => "Untitled Album",
      :genre => "Uncategorized"
    }
    
    def initialize(file_path, library)
      @filepath = file_path
      @library = library
      prepare
    end

    def possibly_sane?
      File.ftype(@filepath) == "file" && !File.zero?(@filepath) && File.readable?(@filepath)
    end
    
    def sane?
      true unless @title.nil? or @artist.nil? or @album.nil? or @genre.nil?
    end

    def inspect
      return "Track: #{@title}, by #{@artist}, from the album #{@album} (#{@genre})"
    end
    
    def missing_tags?
      true if @@defaults.value?(@artist) || @@defaults.value?(@album) || @@defaults.value?(@genre)
    end
    
    protected
    
    # parses ID3 tags
    def prepare
      
      raise InvalidFile if !possibly_sane?
      
      #begin
        # Load a tag from a file
        tag = ID3Lib::Tag.new(@filepath)

        @title = tag.title
        # force default if title is missing in tag
        @title = File::basename(@filepath, ".mp3") if @title.nil? or @title.strip.nil? or @title.is_binary_data?
  
        @album = tag.album
        @album = @@defaults[:album] if @album.nil? or @album.strip.nil? or @album.empty? or @album.is_binary_data?
  
        @artist = tag.artist
        @artist = @@defaults[:artist] if @artist.nil? or @artist.strip.nil? or @artist.is_binary_data?
  
        # parse the genre
        # convert from id3 genre code to its string equivalent
        if tag.genre && (tag.genre =~ /\d/) != nil
          @genre = ID3Lib::Info::Genres[tag.genre.gsub(/[\(\)]/, '').to_i]
        end
        
        # force default if we haven't retrieved a proper genre
        @genre = @@defaults[:genre] if @genre.nil? or @genre.is_binary_data?

        # clean up title field: remove trailing and leading whitespace, 
        # quotes, and brackets, and convert underscores into hyphens
        @title = @title.strip.gsub(/[.\\\/]/, '').gsub('_', ' ')
        
        # strip out slashes from genres, artists, and albums, since they can be directories
        [@artist, @genre, @album].each { |tag| tag.gsub!(/\\\//, '') }
       
        # obey Library preferences regarding file names
        @title = case @library.naming 
        when Library::ByTitle
          @title
        when Library::ByArtistAndTitle
          "#{@artist} - #{@title}"
        when Library::ByAlbumAndTitle
          "#{@album} - #{@title}"
        end
        
        # capitalize each word of each field
        @genre.downcase!
        [@genre, @title, @album, @artist].each { |tag| tag.capitalize_every_word! }
    
      #rescue Exception => e
        #@title, @artist, @album, @genre = nil
      #end

    end


    
  end
end
