require 'lib/abstract_process'

def CreateCollectionProcess

  def self.process_definition
    Ruote.process_definition do
      sequence do
        create_fedora_collection
      end
    end
  end

end