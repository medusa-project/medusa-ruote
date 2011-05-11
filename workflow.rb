#!/usr/bin/env ruby
require 'rubygems'
require 'ruote'
require 'ruote/storage/fs_storage'
require 'fileutils'
require 'eventmachine'
require 'digest'
require 'ruote-amqp'
require 'yajl'
require 'yajl/json_gem'

engine = Ruote::Engine.new(Ruote::Worker.new(Ruote::FsStorage.new('ruote-storage')))
FileUtils.mkdir_p(['in', 'out', 'processing'])

class MoveToProcessingParticipant
  include Ruote::LocalParticipant

  def consume(workitem)
    dir = workitem.fields['dir']
    puts "moving to processing #{dir}"
    FileUtils.mv(File.join('in', "#{dir}_ready"), File.join('processing', dir))
    reply_to_engine(workitem)
  end
end

class MoveToOutParticipant
  include Ruote::LocalParticipant

  def consume(workitem)
    dir = workitem.fields['dir']
    puts "moving to out #{dir}"
    FileUtils.mv(File.join('processing', dir), File.join('out', dir))
    reply_to_engine(workitem)
  end
end

class LocalChecksumParticipant
  include Ruote::LocalParticipant

  def consume(workitem)
    dir = workitem.fields['dir']
    puts "locally checksumming #{dir}"
    sums = Dir[File.join('processing', dir, '*')].collect do |f|
      nil if ['.', '..'].include?(f)
      puts "checksumming #{f}"
      File.open(f) do |file|
        [File.basename(f), Digest::MD5.hexdigest(file.read)]
      end
    end
    puts 'writing checksum file'
    File.open(File.join('processing', dir, 'md5sums'), 'w') do |md5_file|
      sums.compact.each do |row|
        filename, sum = row
        md5_file.puts("#{filename}\t\t#{sum}")
      end
    end
    reply_to_engine(workitem)
  end
end

engine.register do
  participant 'move_to_processing', MoveToProcessingParticipant
  participant 'make_checksums', LocalChecksumParticipant
  participant 'make_file_types', RuoteAMQP::ParticipantProxy, :queue => 'make_file_types'
  participant 'move_to_out', MoveToOutParticipant
end

process = Ruote.process_definition do
  sequence do
    move_to_processing
    make_checksums
    make_file_types
    move_to_out
  end
end

#Since RuoteAMQP::Receiver starts up its own event machine and there doesn't seem to be any way
#to get our server stuff into that we fork here. On the main branch we'll start the RuoteAMQP::Receiver
#and on the child we'll start another event machine that watches directories or does whatever else
#to kick off workflows.
#If ultimately there is a problem with this we can go back to using loop
pid = Kernel.fork
if (pid)
  RuoteAMQP::Receiver.new(engine)
  Process.wait(pid)
else
  EventMachine.run do
    EventMachine::PeriodicTimer.new(5) do
      puts 'checking in directory'
      Dir['in/*_ready'].each do |dir|
        dir_name = File.basename(dir).sub(/_ready$/, '')
        puts "launching ruote process to handle #{dir_name}"
        engine.launch(process, 'dir' => dir_name)
      end
    end
  end
end

