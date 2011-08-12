#!/usr/bin/env ruby
#The main server for Medusa workflow.
#Figures out when to start processes.
#Listens for returns on AMQP and uses them to resume processes.
require 'rubygems'
require 'bundler/setup'
require 'ruote-amqp'
require 'daemons'
require 'eventmachine'

require 'lib/engine'

#How often (in seconds) to check for new processes startup.
#In production this can probably be raised a bit, but a short
#time will be better for development.
POLL_FREQUENCY = 5

working_dir = Dir.getwd
Daemons.run_proc('medusa_server.rb', :dir => 'pid', :log => 'log',
                 :backtrace => true) do
  Dir.chdir(working_dir)
  pid = Kernel.fork
  if (pid)
    RuoteAMQP::Receiver.new(Engine.instance.engine)
    Kernel.at_exit do
      Process.kill('TERM', pid)
    end
    Process.wait(pid)
  else
    EventMachine.run do
      EventMachine::PeriodicTimer.new(POLL_FREQUENCY) do
        #check to see if any processes need to be launched
        #if so, launch them
        #Probably delegate to a process launcher object
      end
    end
  end
end