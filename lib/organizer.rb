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
require 'utility'
require 'kaboom_exceptions'

module Pixy
  class Organizer
    include Pixy::Utility
    include Pixy::ID3

    attr_reader :errors, :successes, :simulating
    
    public
    
    def initialize()
      super()
      
      map_genres
      @simulating = false
      
      log "Organizer: ready to blow up!"
    end
    
    def simulate(library, dest)
      @simulating = true
      process_library(library, dest)
    end
    
    def organize(library)
    end
    
    private
    
    # trims filename, replaces '_' with ' ', and Capitalizes Every Word
    def sanitize(track)
      
    end
    
    # returns a list of all the MP3 files in the given directory as Track objects
    def tracks_in_folder(dir)
      tracks = []
      Dir.new(dir).entries.each do |file|

        
        unless (file =~ /\A[^\.].(.)*.(\.mp3|\.MP3)\z/) == nil
          log "adding track @#{file}"
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
    def process_library(library, dest_dir)
      @errors, @successes = 0, 0
      
      raise InvalidArguments if library.nil?
      
      log "- Housekeeper called for some cleaning, about to start traversing directories in: \n+ Library: #{library.title} @ #{library.path}\n+"
      
      dirs = []
      dirs.push library.path
      
      while !dirs.empty? do
        dir = dirs.pop # get the last directory we came across
        
        Dir.chdir(dir)
        
        log "Browsing #{Dir.pwd}:"
        
        # process current directory's tracks
        tracks = tracks_in_folder(dir)
        
        log "#{tracks.count} tracks found"
        i = 1
        tracks.each do |track|
          begin
            dest = {
              :dir => File.join(dest_dir, track.genre, track.artist, track.album),
              :path => nil
            }
            dest[:path] = File.join(dest[:dir], track.title + '.mp3')
          
            # don't do anything if destination is occupied
            if File::exists?(dest[:path]) 
              puts "\tTrack exists at #{dest[:path]}!"
              next
            end
            
            FileUtils.mkdir_p(dest[:dir])
            if @simulating
              FileUtils.touch(dest[:path])
            else
              #FileUtils.cp(track.filepath, dest[:path]) 
            end
            
            log "\t#{i}. #{track.inspect}"
            @successes += 1
            i += 1
          rescue Exception => e
            log "faced an issue: #{e.message}"
            @errors += 1
          end
          
        end
        
        Dir.new(dir).entries.each do |entry|
          # skip '.', '..' or any other file, we need directories
          next unless File::directory?(entry) and (entry =~ /\A[\.]{1,2}\z/) == nil
                    
          dirs.push("#{Dir.pwd}/#{entry}")
          
          log "\t+ added directory to queue: #{dirs.last.gsub(library.path + "/", '')}"
          
        end
        
      end
      
      log "- House cleaning is over: \nI was able to process #{@successes} mp3 files, and failed to process #{@errors} mp3 files.\nI hope you enjoy my services. Bye!"
    end
    
  end

end