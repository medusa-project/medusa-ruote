#The workflow engine for Medusa.
require 'singleton'
require 'ruote'
require 'ruote-amqp'
require 'ruote/storage/fs_storage'

class MedusaEngine
  include Singleton
  attr_accessor :engine, :config

  def initialize
    read_config
    self.engine = Ruote::Engine.new(Ruote::Worker.new(Ruote::FsStorage.new(self.config['storage_directory'])))
    self.register_participants
  end

  protected

  #List all available participants here
  def register_participants
    self.engine.register do

    end
  end

  def read_config
    self.config = YAML.load_file('config/engine.yml')
  end

end