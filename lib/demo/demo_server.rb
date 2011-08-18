#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'medusa')
require 'bundler/setup'
require 'ruote/storage/fs_storage'
require 'fileutils'
require 'eventmachine'
require 'ruote-amqp'
require 'daemons'

require 'demo/demo_process'
require 'demo/demo_engine'

#needed only for the demo process
FileUtils.mkdir_p(['in', 'out', 'processing'])

#set up receiving amqp return events and watching the
#in directory for new dirs to be processes
#Note that anything that needs to touch a file needs to
#open it up inside the Daemons.run_proc call (e.g. a logger,
#the engine stuff, etc.).
working_dir = Dir.getwd
Daemons.run_proc('demo_server.rb', :dir => 'pid', :log => 'log',
                 :backtrace => true) do
  Dir.chdir(working_dir)
  pid = Kernel.fork
  if (pid)
    RuoteAMQP::Receiver.new(Medusa::DemoEngine.instance.engine)
    Kernel.at_exit do
      Process.kill('TERM', pid)
    end
    Process.wait(pid)
  else
    EventMachine.run do
      EventMachine::PeriodicTimer.new(5) do
        puts 'checking in directory'
        Dir['in/*_ready'].each do |dir|
          dir_name = File.basename(dir).sub(/_ready$/, '')
          puts "launching ruote process to handle #{dir_name}"
          Medusa::DemoEngine.instance.engine.launch(Medusa::DemoProcess.process, 'dir' => dir_name)
        end
      end
    end
  end
end
