require 'rubygems'
require 'fileutils'

def recursive_rmdir(dir)

  # find my children directories
  Dir.glob("#{dir}/*").each do |file|
    if File.directory? file then
      #puts "found a directory: #{file}"
      recursive_rmdir(file)
    end
  end

  # am I empty?
  if Dir.glob("#{dir}/*").empty?
    puts "removing dir #{dir}"
    # delete me
    FileUtils.rmdir(dir) rescue nil
  end

end

root = File.join("home", "kandie", "Test", "Pop")
root = "/#{root}"
recursive_rmdir(root)
