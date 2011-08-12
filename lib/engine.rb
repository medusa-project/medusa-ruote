#The workflow engine for Medusa.
require 'singleton'
require 'ruote'
require 'ruote-amqp'

class MedusaEngine
  require 'singleton'
  attr_accessor :engine

  def initialize
    self.engine = Ruote::Engine.new(Ruote::Worker.new(Ruote::FsStorage.new('medusa-ruote-storage')))
    self.register_participants
  end

  #List all available participants here
  def register_participants
    self.engine.register do

    end
  end
end