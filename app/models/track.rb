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
    
    protected
    
    # parses ID3 tags
    def prepare
      
      raise InvalidFile if !possibly_sane?
      
      #begin
        # Load a tag from a file
        tag = ID3Lib::Tag.new(@filepath)

        @title = tag.title
        # force default if title is missing in tag
        @title = File::basename(@filepath, "mp3") if @title.nil? or @title.strip.nil? or @title.is_binary_data?
  
        @album = tag.album
        @album = @@defaults[:album] if @album.nil? or @album.strip.nil? or @album.empty? or @album.is_binary_data?
  
        @artist = tag.artist
        @artist = @@defaults[:artist] if @artist.nil? or @artist.strip.nil? or @artist.is_binary_data?
  
        # parse the genre
        # convert from id3 genre code to its string equivalent
        if tag.genre && (tag.genre =~ /\d/) != nil
          @genre = ID3Lib::Info::Genres[tag.genre.gsub(/[\(\)]/, '').to_i]
        end
        
        # if we have a string genre, assign it, otherwise, force default
        #@genre ||= tag.genre
        @genre = @@defaults[:genre] if @genre.nil? or @genre.is_binary_data?

        # clean up title field: remove trailing and leading whitespace, 
        # quotes, and brackets, and convert underscores into hyphens
        @title.strip.gsub(/\.'"()/, '').gsub('_', ' ')

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
        @genre = @genre.downcase.split.each { |word| word.capitalize! }.join(" ")
        @title = @title.split.each { |word| word.capitalize! }.join(" ")
        @album = @album.split.each { |word| word.capitalize! }.join(" ")
        @artist = @artist.split.each { |word| word.capitalize! }.join(" ")
    
      #rescue Exception => e
      #  @title, @artist, @album, @genre = nil
      #end

    end


    
  end
end
