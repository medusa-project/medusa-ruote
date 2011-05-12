require 'ruote'
require 'ruote-amqp'
require 'singleton'
require 'lib/amqp_services/amqp_file_type_service'
require 'lib/local_services/local_checksum_participant'
require 'lib/local_services/move_to_out_participant'
require 'lib/local_services/move_to_processing_participant'

class DemoEngine
  include Singleton
  attr_accessor :engine

  def initialize
    self.engine = engine = Ruote::Engine.new(Ruote::Worker.new(Ruote::FsStorage.new('ruote-storage')))
    self.register_participants
  end

  def register_participants
    self.engine.register do
      participant 'move_to_processing', MoveToProcessingParticipant
      participant 'make_checksums', LocalChecksumParticipant
      participant 'make_file_types', RuoteAMQP::ParticipantProxy, :queue => AMQPFileTypeService.amqp_listen_queue
      participant 'move_to_out', MoveToOutParticipant
    end
  end
end



