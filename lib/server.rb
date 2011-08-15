#!/usr/bin/env ruby
#The main server for Medusa workflow.
#Figures out when to start processes.
#Listens for returns on AMQP and uses them to resume processes.
require 'rubygems'
require 'bundler/setup'
require 'ruote-amqp'
require 'daemons'
require 'eventmachine'
require 'bagit'
require 'filescan'
require 'lib/engine'
require 'lib/utils/bag_utils'

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
          start_incoming_bag_checker
          start_process_launcher
        end
      end
    end
  end

  protected

  def read_config(base_dir)
    self.config = YAML.load_file(File.join(base_dir, 'config', 'server.yml'))
  end

  #Check the incoming directory for valid bags. Move valid bags to the ready
  #directory.
  def start_incoming_bag_checker
    start_periodic_timer_with_mutex() do
      Filescan.new(self.config['incoming_directory'], false, false).each_dirname do |dir_name|
        #make sure files have been unmodified for a while. Not strictly necessary, but cheaper
        #than checking the whole bag each time while it's still being copied in.
        next unless directory_unmodified?(dir_name, self.config['incoming_directory_processing_delay'])
        #make sure we have a valid bag
        begin
          next unless BagUtils.extract_bag(dir_name)
        rescue InvalidBagError
          next
          #TODO? At some point maybe we'll also want to report invalid bags
          #that have been sitting around for a long time. Perhaps email to a server admin
          #or something.
        end
        #Here we have a good bag. Move it to the ready directory.
        FileUtils.mv(dir_name, File.join(self.config['ready_directory'], File.basename(dir_name)))
      end
    end
  end

  #Return true if each file (recursively) under the given directory has not been modified
  #for <delay_time> seconds from when this function is called.
  #If there are no files under the directory return false.
  def directory_unmodified?(directory_name, delay_time)
    now = Time.now
    last = directory_last_modified(directory_name)
    return (last and (now - last > delay_time))
  end

  #Return the latest time a file under this directory (recursively) has been modified,
  #or nil if there are no files.
  def directory_last_modified(directory_name)
    last = nil
    Filescan.new(directory_name, true, false).each_file do |file, file_name|
      last ||= file.mtime
      last = [last, file.mtime].max
    end
    return last
  end

  #Check the ready directory for directories.
  #Figure out what processes to launch on each, move to processing directory,
  #and launch the process.
  def start_process_launcher
    start_periodic_timer_with_mutex() do

    end
  end

  #run a block under a periodic timer but with a mutex.
  #If the timer is called but the mutex is locked then just skip the block
  #for that iteration.
  def start_periodic_timer_with_mutex(poll_frequency = self.config['poll_frequency'])
    mutex = Mutex.new
    EventMachine::PeriodicTimer.new(poll_frequency.to_i) do
      if mutex.try_lock
        begin
          yield
        ensure
          mutex.unlock
        end
      end
    end
  end

end