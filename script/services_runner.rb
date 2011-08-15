#!/usr/bin/env ruby
require 'rubygems'
require 'filescan'

unless action = ARGV[0]
  puts "USAGE: #{$PROGRAM_NAME} < start | stop | restart | run | ... > (see Daemons gem for all actions)"
  exit
end
Filescan.new('lib/runners', true, false).each_filename do |name|
  puts "Executing #{name} #{action}"
  system(name, action)
end
