require 'ruote'
require 'ruote-amqp'
require 'singleton'
require 'lib/demo/services/amqp_file_type_service'
require 'lib/services/amqp_initial_ingest_service'
require 'lib/demo/services/local_checksum_participant'
require 'lib/demo/services/move_to_out_participant'
require 'lib/demo/services/move_to_processing_participant'

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


