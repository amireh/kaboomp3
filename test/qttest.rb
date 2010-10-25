require 'rubygems'
require 'Qt4'
require 'qtuitools'
require '../lib/utility'

ENV['APP_ROOT'] ||= File.expand_path("..")

include Pixy::Utility

@qt = { }
@qt[:app] = Qt::Application.new(ARGV)
@qt[:loader] = Qt::UiLoader.new

