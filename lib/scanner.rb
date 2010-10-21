# Music Library Housekeeper
# Navigate through my music library, grab each file and:
# => parse its id3 information, and if it contains Genre and Artist entries
# => create a directory (if it does not exist) named under the Genre's value
# => create a subdirectory (if it does not exist) named under the Artist's value
# => create a subdirectory (if it does not exist) named under the Album's value
# => rename the file to "Artist - Song Title.mp3" & move it
#
# our end result should be:
# => Music/Genre/Artist/Album/Artist - Song Title.mp3
#
# in the case of missing ID3 entries:
# a) if the track has an undefined genre entry, identified by either a blank field or
# => a value similar to "Unknown", "Genre", "General", "Music", then we shall create
# => the artist subdirectory in a centralised "Uncategorized" folder /Uncategorized
#
# b) if the track has an undefined artist entry, identified by something similar to the above
# => then we shall move the song to Uncategorized/Singles
#
# c) if the track has an undefined album entry, the track will be moved under "Untitled Album"
#
# failsafe result should be:
# => Music/Uncategorized/Unknown Artist/Unknown Album/(Song Title) || (Filename).mp3

require 'rubygems'
require 'id3lib'

module Pixy
  
  LIBRARY = '/Volumes/bunghole/Music' # path of my music library
  DEST = '/Volumes/bunghole/Music_u'
  #ROOT = Dir.pwd # our app path
  
  @genres = nil
  
  def self.map_genres()
    @genres ||= []
    @genres[0] = "Blues"
    @genres[1] = "Classic Rock"
    @genres[2] = "Country"
    @genres[3] = "Dance"
    @genres[4] = "Disco"
    @genres[5] = "Funk"
    @genres[6] = "Grunge"
    @genres[7] = "Hip-Hop"
    @genres[8] = "Jazz"
    @genres[9] = "Metal"
    @genres[10] = "New Age"
    @genres[11] = "Oldies"
    @genres[12] = "Other"
    @genres[13] = "Pop"
    @genres[14] = "R&B"
    @genres[15] = "Rap"
    @genres[16] = "Reggae"
    @genres[17] = "Rock"
    @genres[18] = "Techno"
    @genres[19] = "Industrial"
    @genres[20] = "Alternative"
    @genres[21] = "Ska"
    @genres[22] = "Death Metal"
    @genres[23] = "Pranks"
    @genres[24] = "Soundtrack"
    @genres[25] = "Euro-Techno"
    @genres[26] = "Ambient"
    @genres[27] = "Trip-Hop"
    @genres[28] = "Vocal"
    @genres[29] = "Jazz+Funk"
    @genres[30] = "Fusion"
    @genres[31] = "Trance"
    @genres[32] = "Classical"
    @genres[33] = "Instrumental"
    @genres[34] = "Acid"
    @genres[35] = "House"
    @genres[36] = "Game"
    @genres[37] = "Sound Clip"
    @genres[38] = "Gospel"
    @genres[39] = "Noise"
    @genres[40] = "AlternRock"
    @genres[41] = "Bass"
    @genres[42] = "Soul"
    @genres[43] = "Punk"
    @genres[44] = "Space"
    @genres[45] = "Meditative"
    @genres[46] = "Instrumental Pop"
    @genres[47] = "Instrumental Rock"
    @genres[48] = "Ethnic"
    @genres[49] = "Gothic"
    @genres[50] = "Darkwave"
    @genres[51] = "Techno-Industrial"
    @genres[52] = "Electronic"
    @genres[53] = "Pop-Folk"
    @genres[54] = "Eurodance"
    @genres[55] = "Dream"
    @genres[56] = "Southern Rock"
    @genres[57] = "Comedy"
    @genres[58] = "Cult"
    @genres[59] = "Gangsta"
    @genres[60] = "Top Forty"
    @genres[61] = "Christian Rap"
    @genres[62] = "Pop/Funk"
    @genres[63] = "Jungle"
    @genres[64] = "Native American"
    @genres[65] = "Cabaret"
    @genres[66] = "New Wave"
    @genres[67] = "Psychadelic"
    @genres[68] = "Rave"
    @genres[69] = "Showtunes"
    @genres[70] = "Trailer"
    @genres[71] = "Lo-Fi"
    @genres[72] = "Tribal"
    @genres[73] = "Acid Punk"
    @genres[74] = "Acid Jazz"
    @genres[75] = "Polka"
    @genres[76] = "Retro"
    @genres[77] = "Musical"
    @genres[78] = "Rock & Roll"
    @genres[79] = "Hard Rock"
    @genres[80] = "Folk"
    @genres[81] = "Folk-Rock"
    @genres[82] = "National Folk"
    @genres[83] = "Swing"
    @genres[84] = "Fast Fusion"
    @genres[85] = "Bebob"
    @genres[86] = "Latin"
    @genres[87] = "Revival"
    @genres[88] = "Celtic"
    @genres[89] = "Bluegrass"
    @genres[90] = "Avantgarde"
    @genres[91] = "Gothic Rock"
    @genres[92] = "Progressive Rock"
    @genres[93] = "Psychedelic Rock"
    @genres[94] = "Symphonic Rock"
    @genres[95] = "Slow Rock"
    @genres[96] = "Big Band"
    @genres[97] = "Chorus"
    @genres[98] = "Easy Listening"
    @genres[99] = "Acoustic"
    @genres[100] = "Humour"
    @genres[101] = "Speech"
    @genres[102] = "Chanson"
    @genres[103] = "Opera"
    @genres[104] = "Chamber Music"
    @genres[105] = "Sonata"
    @genres[106] = "Symphony"
    @genres[107] = "Booty Bass"
    @genres[108] = "Primus"
    @genres[109] = "Porn Groove"
    @genres[110] = "Satire"
    @genres[111] = "Slow Jam"
    @genres[112] = "Club"
    @genres[113] = "Tango"
    @genres[114] = "Samba"
    @genres[115] = "Folklore"
    @genres[116] = "Ballad"
    @genres[117] = "Power Ballad"
    @genres[118] = "Rhythmic Soul"
    @genres[119] = "Freestyle"
    @genres[120] = "Duet"
    @genres[121] = "Punk Rock"
    @genres[122] = "Drum Solo"
    @genres[123] = "A capella"
    @genres[124] = "Euro-House"
    @genres[125] = "Dance Hall"    
  end
  
  def self.id3_genre(code)
    map_genres() if @genres.nil?
    
    return @genres[code.to_i]
  end
  
  class Housekeeper
    
    attr_reader :errors, :successes
        
    def log(msg)
      puts msg
    end
    
    # trims filename, replaces '_' with ' ', and Capitalizes Every Word
    def sanitize(track)
      
    end
    
    # returns a list of all the MP3 files in the given directory as Track objects
    def tracks_in_folder(dir)
      tracks = []
      Dir.new(dir).entries.each do |file|

        
        unless (file =~ /\A[^\.].(.)*.(\.mp3|\.MP3)\z/) == nil
          track = Track.new(file)
          
          if track.sane?
            # add the track to the processing queue
            tracks.push(track)
          else
            @errors += 1
          end
          
        end

      end

      tracks
    end
    
    # navigate library and clean up the tracks
    def go(root)
      @errors, @successes = 0, 0
      
      log "- Housekeeper called for some cleaning, about to start traversing directories in: \n+ Library: #{root}\n+"
      
      dirs = []
      dirs.push root
      
      while !dirs.empty? do
        dir = dirs.pop # get the last directory we came across
        
        Dir.chdir(dir)
        
        log "+ Browsing #{Dir.pwd}:"
        
        # process current directory's tracks
        tracks = tracks_in_folder(dir)
        
        i = 1
        tracks.each do |track|
          begin
            dest = {
              :dir => File.join(DEST, track.genre, track.artist, track.album),
              :path => nil
            }
            dest[:path] = File.join(dest[:dir], track.title + '.mp3')
          
            puts "\tTrack exists at #{dest[:path]}!" and next if File::exists?(dest[:path]) # don't do anything if destination is occupied
            
            FileUtils.mkdir_p(dest[:dir])
            FileUtils.cp(track.filepath, dest[:path])
            
            log "\t#{i}. #{track.inspect}"
            @successes += 1
            i += 1
          rescue Exception => e
            @errors += 1
          end
          
        end
        
        Dir.new(dir).entries.each do |entry|
          # skip '.', '..' or any other file, we need directories
          next unless File::directory?(entry) and (entry =~ /\A[\.]{1,2}\z/) == nil
                    
          dirs.push("#{Dir.pwd}/#{entry}")
          
          log "\t+ added directory to queue: #{dirs.last.gsub(LIBRARY + "/", '')}"
          
        end
        
      end
      
      log "- House cleaning is over: \nI was able to process #{@successes} mp3 files, and failed to process #{@errors} mp3 files.\nI hope you enjoy my services. Bye!"
    end
    
  end

  class Track
    
    attr_reader :title, :album, :artist, :genre, :filepath
        
    def initialize(file_path)
      @filepath = file_path
      
      prepare
    end
    
    # parses ID3 tags
    def prepare
      
      
      begin
        
        # Load a tag from a file
        tag = ID3Lib::Tag.new(@filepath)

        @title = tag.title
        @title = File::basename(@filepath, "mp3") if @title.nil? or @title.strip.nil? or @title.is_binary_data?
      
        @album = tag.album
        @album = "Untitled Album" if @album.nil? or @album.strip.nil? or @album.empty? or @album.is_binary_data?
      
        @artist = tag.artist
        @artist = "Unknown Artist" if @artist.nil? or @artist.strip.nil? or @artist.is_binary_data?
      
        # parse the genre
        # convert from id3 genre code to its string equivalent
        if tag.genre && (tag.genre =~ /\d/) != nil
          @genre = Pixy.id3_genre(tag.genre.gsub(/[\(\)]/, ''))
        end
        # if we have a string genre, assign it, otherwise, force default
        @genre ||= tag.genre
        @genre = "Uncategorized" if @genre.nil? or @genre.is_binary_data?
      
        # clean up title field: remove trailing and leading whitespace, 
        # quotes, and brackets, and convert underscores into hyphens
        @title.strip.gsub(/\.'"()/, '').gsub('_', ' ')
      
        @title = "#{@artist} - #{@title}" unless @artist == "Unknown Artist"
      
        @title.capitalize!
        @album.capitalize!
        @artist.capitalize!
        
      rescue Exception => e
        @title, @artist, @album, @genre = nil
      end
    
    end
    
    def sane?
      true unless @title.nil? or @artist.nil? or @album.nil? or @genre.nil?
    end
    
    def inspect
      return "Track: #{@title}, by #{@artist}, from the album #{@album} (#{@genre})"
    end
    
  end
end

housekeeper = Pixy::Housekeeper.new()
housekeeper.go(Pixy::LIBRARY)