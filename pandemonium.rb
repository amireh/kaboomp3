#!/usr/bin/ruby

require 'rubygems'
require 'qt4'
require 'qtuitools'
 
a = Qt::Application.new(ARGV)

#if ARGV.length == 0
#  exit
#end

#if ARGV.length == 1
  file = Qt::File.new(File.join("app", "views", "main_window.ui"))
  file.open(Qt::File::ReadOnly)

  loader = Qt::UiLoader.new
  window = loader.load(file, nil)
  file.close
  if (window.nil?)
    print "Error. Window is nil.\n"
    exit
  end
  window.show
  a.connect(a, SIGNAL('lastWindowClosed()'), a, SLOT('quit()'))
  a.exec
#end