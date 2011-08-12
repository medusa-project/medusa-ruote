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

class MedusaServer

  attr_accessor :config

  def start
    working_dir = Dir.getwd
    read_config(working_dir)
    Daemons.run_proc('medusa_server.rb', :dir => 'pid', :log => 'log',
                     :backtrace => true) do
      Dir.chdir(working_dir)
      pid = Kernel.fork
      if (pid)
        RuoteAMQP::Receiver.new(MedusaEngine.instance.engine)
        Kernel.at_exit do
          Process.kill('TERM', pid)
        end
        Process.wait(pid)
      else
        EventMachine.run do
          EventMachine::PeriodicTimer.new(self.config['poll_frequency'].to_i) do
            #check to see if any processes need to be launched
            #if so, launch them
            #Probably delegate to a process launcher object
          end
        end
      end
    end
  end

  def read_config(base_dir)
    self.config = YAML.load_file(File.join(base_dir, 'config', 'server.yml'))
  end

end