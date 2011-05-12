#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'ruote'
require 'ruote/storage/fs_storage'
require 'fileutils'
require 'eventmachine'
require 'ruote-amqp'
require 'yajl'
require 'yajl/json_gem'
require 'daemons'
require 'lib/amqp_services/amqp_file_type_service'
require 'lib/local_services/local_checksum_participant'
require 'lib/local_services/move_to_out_participant'
require 'lib/local_services/move_to_processing_participant'

engine = Ruote::Engine.new(Ruote::Worker.new(Ruote::FsStorage.new('ruote-storage')))

FileUtils.mkdir_p(['in', 'out', 'processing'])

engine.register do
  participant 'move_to_processing', MoveToProcessingParticipant
  participant 'make_checksums', LocalChecksumParticipant
  participant 'make_file_types', RuoteAMQP::ParticipantProxy, :queue => AMQPFileTypeService.amqp_listen_queue
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

#Also - I'm having problems getting this to daemonize this way. Obviously I'd like to use something
#like Daemons to make it as simple as possible, but the normal patterns seem to fail (perhaps because of the
#fork).
#So as another idea, what would happen if we had another script that only ran
#RuoteAMQP::Receiver and did nothing else (so it would define an engine on the same storage and
#just use it to pass along workitems that it got).
#It's possible that would create synchronization problems of some sort - but it's also possible that
#it wouldn't. It does appear that the FsStorage uses locks to prevent collisions of workers from a single
#engine, and I'd think that would work with more than one engine.
#Some research suggests that this may be possible. A possible problem is if 'engine level' variables are stored,
#but I don't know exactly what this means in a practical sense (also that thread was old and the problem
#may be solved).
#It may also be some other sort of problem with Daemons - there's a lot of fiddly stuff you need to make
#sure you get right involving the working directory, streams, etc. I need to review some other stuff I've done
#with it to see if that provides any hints. 
pid = Kernel.fork
if (pid)
  RuoteAMQP::Receiver.new(engine)
  Kernel.at_exit do
    Process.kill('HUP', pid)
  end
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
