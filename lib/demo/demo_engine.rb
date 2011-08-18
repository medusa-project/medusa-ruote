require File.join(File.dirname(__FILE__), '..', 'medusa')
require 'ruote-amqp'
require 'singleton'
require 'demo/services/amqp_file_type_service'
require 'services/amqp_initial_ingest_service'
require 'demo/services/local_checksum_participant'
require 'demo/services/move_to_out_participant'
require 'demo/services/move_to_processing_participant'

module Medusa
  class DemoEngine
    include Singleton
    attr_accessor :engine

    def initialize
      self.engine = Ruote::Engine.new(Ruote::Worker.new(Ruote::FsStorage.new('ruote-storage')))
      self.register_participants
    end

    def register_participants
      self.engine.register do
        participant 'move_to_processing', MoveToProcessingParticipant
        participant 'make_checksums', LocalChecksumParticipant
        participant 'make_file_types', RuoteAMQP::ParticipantProxy, :queue => AMQPFileTypeService.amqp_listen_queue
        participant 'move_to_out', MoveToOutParticipant
        participant 'initial_ingest', RuoteAMQP::ParticipantProxy, :queue => AMQPInitialIngestService.amqp_listen_queue
      end
    end
  end
end


