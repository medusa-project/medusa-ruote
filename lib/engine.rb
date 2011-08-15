#The workflow engine for Medusa.
require 'singleton'
require 'ruote'
require 'ruote-amqp'
require 'ruote/storage/fs_storage'

#participants
require 'lib/services/create_fedora_collection'

class MedusaEngine
  include Singleton
  attr_accessor :engine
  attr_accessor :storage_directory

  def initialize
    read_config
    self.engine = Ruote::Engine.new(Ruote::Worker.new(Ruote::FsStorage.new(storage_directory)))
    self.register_participants
  end

  protected

  #List all available participants here
  def register_participants
    self.engine.register do
      participant 'create_fedora_collection', RuoteAMQP::ParticipantProxy, :queue => CreateFedoraCollection.amqp_listen_queue
    end
  end

  def read_config
    config = YAML.load_file('config/engine.yml')
    self.storage_directory = config['storage_directory']
  end

end