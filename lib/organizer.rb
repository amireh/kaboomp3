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

    attr_reader :stats, :errors, :simulating
    attr_accessor :tracking_errors, :tracking_stats, :showing_progress
    
    public
    
    def initialize()
      super()
      
      @tracking_stats = true
      @tracking_errors = true
      @showing_progress = true
      
      @simulating = false
      @errors = { :dest_exists => 0 }
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
      @stats[:timer][:begin] = Time.now
      
      @simulating = true
      process_library(library, dest)

      @stats[:timer][:end] = Time.now
      
      @stats[:timer][:elapsed] = @stats[:timer][:end] - @stats[:timer][:begin]
      
			@stats
    end
    
    def organize(library)
    end
    
    def tracking_errors?
      return @tracking_errors
    end
    
    def tracking_stats?
      return @tracking_stats
    end
      
    private
    
    # trims filename, replaces '_' with ' ', and Capitalizes Every Word
    def sanitize(track)
      
    end
    
		def track_error(e)
			@errors[e.class.to_s.to_sym] ||= 0
			@errors[e.class.to_s.to_sym] += 1
		end
		
    # returns a list of all the MP3 files in the given directory as Track objects
    def tracks_in_folder(dir)
      tracks = []
      Dir["#{dir}/*.mp3"].each do |file|

        #log "processing #{file}" 
        #unless (file =~ /\A[^\.].(.)*.(\.mp3|\.MP3)\z/) == nil

          #@stats[:nr_tracks] += 1 if tracking_stats?
          
					begin
	          track = Track.new(file)
	          tracks.push(track) if track.sane?
					rescue Exception => e
						track_error(e) if tracking_errors?
						@stats[:failures] += 1 if tracking_stats?
          end

          
        end

      #end

      tracks
    end

    def update_progress
      Pixy::Pandemonium.instance.ui[:controllers][:libraries].update_progress(@stepper, @step)
    end
    
    def showing_progress?
      @showing_progress
    end
    
    def find_nr_tracks(library)
      count = 0
      
      dirs = []
      dirs.push library.path
      
      while !dirs.empty? do
        dir = dirs.pop # get the last directory we came across
        
        Dir.chdir(dir)
        count += Dir["*.mp3"].count
        
        Dir["*/"].each { |entry| dirs.push(File.join(Dir.pwd, entry)) }
      end
      
      count
    end
        
    # navigate library and clean up the tracks
    def process_library(library, dest_dir)
      
      raise InvalidArguments if library.nil?
			raise InvalidPath if !File.exists?(library.path)
      
      log "Organizer called for some blowing up action, about to start traversing directories in:"
      log "Library: #{library.title} @ #{library.path}"
      if showing_progress?
        log "determining number of tracks in library..."
        @stats[:nr_tracks] = find_nr_tracks(library)
        log "#{@stats[:nr_tracks]} tracks found"
        
        if @stats[:nr_tracks] == 0 
          return empty_library 
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
      
      while !dirs.empty? do
        dir = dirs.pop # get the last directory we came across
        
        Dir.chdir(dir)
        
        #log "Browsing #{Dir.pwd}:"
        
        # process current directory's tracks
        tracks = tracks_in_folder(dir)
        
        #log "#{tracks.count} tracks found"
        #i = 1
        tracks.each do |track|
        
          begin
            dest = {
              :dir => File.join(dest_dir, track.genre, track.artist, track.album),
              :path => nil
            }
            dest[:path] = File.join(dest[:dir], track.title + '.mp3')
          
            # don't do anything if destination is occupied
            if File::exists?(dest[:path]) 
              log "\tTrack exists at #{dest[:path]}!"
              @errors[:dest_exists] += 1
              next
            end
            
            FileUtils.mkdir_p(dest[:dir]) rescue nil # ignore if directory exists
            if @simulating
              FileUtils.touch(dest[:path])
            else
              #FileUtils.cp(track.filepath, dest[:path]) 
            end
            
            #log "\t#{i}. #{track.inspect}"
            #@successes += 1
            #i += 1
          rescue Exception => e
            log "faced an issue: #{e.message}"
            @stats[:failures] += 1 if tracking_stats?
						track_error(e) if tracking_errors?
          end
          if showing_progress?
            @stepper += 1
            if @stepper % @step == 0 then update_progress end
          end
        end
        
        #Dir.new(dir).entries.each do |entry|
        Dir["*/"].each do |entry|
          # skip '.', '..' or any other file, we need directories
          #next unless File::directory?(entry) and (entry =~ /\A[\.]{1,2}\z/) == nil
                    
          dirs.push("#{Dir.pwd}/#{entry}")
          #log "\t+ added directory to queue: #{dirs.last.gsub(library.path + "/", '')}"
          
        end
        
      end
    end
      
    def empty_library
      log "its an empty library"
    end
  end
end