#!/usr/bin/env ruby
require 'rubygems'
require 'filescan'

unless action = ARGV[0]
  puts "USAGE: #{$PROGRAM_NAME} < start | stop | restart | run | ... > (see Daemons gem for all actions)"
  exit
end
#Make sure the main server starts first
puts "Executing main server #{action}"
system('lib/medusa/runners/server_runner.rb', action)
#Then run the other servers
Filescan.new('lib/medusa/runners', true, false).each_filename do |name|
  next if name.match(/server_runner\.rb$/)
  puts "Executing #{name} #{action}"
  system(name, action)
end
