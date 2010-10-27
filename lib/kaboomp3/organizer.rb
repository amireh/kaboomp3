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
require 'kaboomp3/utility'
require 'kaboomp3/exceptions'

module Pixy
  class Organizer
    include Pixy::Utility

    attr_reader :stats, :errors, :simulating
    attr_accessor :tracking_errors, 
      :tracking_stats, 
      :showing_progress, 
      :library

    
    public
    
    def initialize()
      super()
      
      @tracking_stats = true
      @tracking_errors = true
      @showing_progress = true
      
      @simulating = false
      @errors = { }
			@stats = { 
			  :failures => 0,
			  :nr_tracks => 0,
			  :timer => { 
			    :begin => nil, 
			    :end => nil, 
			    :elapsed => nil
			  },
			  :progress => 0
			}
      
      log "Organizer: ready to blow up!"
    end
    
    def simulate(library, dest)
      @library = library
      @simulating = true

      @stats[:timer][:begin] = Time.now        
        process_library(library, dest)
      @stats[:timer][:end] = Time.now
      @stats[:timer][:elapsed] = @stats[:timer][:end] - @stats[:timer][:begin]
      
			return @stats, @errors
    end
    
    def organize(library)
      @simulating = false
      
      @errors.clear
      
      @stats[:timer][:begin] = Time.now        
        process_library(library, library.path)
      @stats[:timer][:end] = Time.now
      @stats[:timer][:elapsed] = @stats[:timer][:end] - @stats[:timer][:begin]
            
      return @stats, @errors
    end
    
    def tracking_errors?
      return @tracking_errors
    end
    
    def tracking_stats?
      return @tracking_stats
    end

    def update_me(target)
      @update_target = target
    end
  
    private
    
		def track_error(e)
			if @errors.has_key?(e.class.to_s.to_sym)
			  @errors[e.class.to_s.to_sym][:count] += 1
			else
			  @errors[e.class.to_s.to_sym] = { :count => 1, :message => e.message }
		  end
		end
		
    # returns a list of all the MP3 files in the given directory as Track objects
    def tracks_in_folder(dir)
      tracks = []
      Dir["#{dir}/*.mp3"].each do |file|
					begin
	          track = Track.new(file, @library)
	          tracks.push(track) if track.sane?
					rescue Exception => e
						track_error(e) if tracking_errors?
						@stats[:failures] += 1 if tracking_stats?
          end
        end

      tracks
    end

    def showing_progress?
      @showing_progress
    end
    

    
    def update_progress
      @update_target.update_progress(@stepper / @step)
    end
    
    def find_nr_tracks(library)
      count = 0
      
      dirs = []
      dirs.push library.path
      
      until dirs.empty? do
        dir = dirs.pop # get the last directory we came across
        
        Dir.chdir(dir)
        count += Dir["*.mp3"].count
        
        Dir["*/"].each { |entry| dirs.push(File.join(Dir.pwd, entry)) }
      end
      
      count
    end
        
    # navigate library and clean up the tracks
    def process_library(library, dest_dir)
      
      @stats[:failures] = 0
      
			raise InvalidLibrary.new(Library::InvalidPath) if library.path.nil? or File.zero?(library.path)
      
      log "Organizer called for some blowing up action, about to start traversing directories in:"
      log "Library: #{library.title} @ #{library.path}"
      
      if showing_progress?
        log "determining number of tracks in library..."
        @stats[:nr_tracks] = find_nr_tracks(library)
        log "#{@stats[:nr_tracks]} tracks found"
        
        if @stats[:nr_tracks] == 0 
          raise InvalidLibrary.new(Library::EmptyLibrary)
        end
        
        if @stats[:nr_tracks] < 100
          @step = (100 / @stats[:nr_tracks]).floor
        else
          @step = (@stats[:nr_tracks] / 100).ceil
        end
        log "progress step is #{@step}"
        
      end
      
      @stepper = 0
      
      dirs = []
      dirs.push library.path
      
      until dirs.empty? do
        dir = dirs.pop # get the last directory we came across
        
        Dir.chdir(dir)

        # process current directory's tracks
        tracks = tracks_in_folder(dir)
        
        tracks.each do |track|
          begin
            dest = {
              :dir => File.join(dest_dir),
              :path => nil
            }
            
            dest[:dir] = File.join(dest[:dir], track.genre) if @library.sort_by_genre?
            dest[:dir] = File.join(dest[:dir], track.artist) if @library.sort_by_artist?
            dest[:dir] = File.join(dest[:dir], track.album) if @library.sort_by_album?
            dest[:path] = File.join(dest[:dir], track.title + '.mp3')
            #puts track.inspect if track.missing_tags?
          
            # don't do anything if destination is occupied
            raise DestinationExists, "#{dest[:path]}" if File::exists?(dest[:path]) 
            
            FileUtils.mkdir_p(dest[:dir]) rescue nil # ignore if directory exists
            if @simulating
              FileUtils.touch(dest[:path])
            else
              FileUtils.mv(track.filepath, dest[:path]) 
            end
          
          rescue Exception => e
            #log "faced an issue: #{e.message}"
            @stats[:failures] += 1 if tracking_stats?
						track_error(e) if tracking_errors?
          end
          if showing_progress?
            @stepper += 1
            if @stepper % @step == 0 then update_progress end
          end
          
        end # begin block
        
        # add subdirectories to the queue
        Dir["*/"].each { |entry| dirs.push("#{Dir.pwd}/#{entry}") }
        
      end # while block
      
      cleanup_empty_dirs(library.path)
      
    end # process_library
    
  end # class Organizer
end # module Pixy
