require 'rake'

ENV['APP_ROOT'] ||= File.expand_path(File.dirname(__FILE__))

# load .rake files in lib/tasks
$LOAD_PATH << File.join(ENV['APP_ROOT'], 'lib', 'tasks')
Dir.new(File.join(ENV['APP_ROOT'], "lib", "tasks")).entries.each do |rakefile|
  load rakefile unless (rakefile =~ /^(.)*.rake$/) == nil
end

desc "KabooMP3!"
task :run do |t, args|
  require 'kaboomp3'
  Pixy::Kaboomp3.instance.run!
end
