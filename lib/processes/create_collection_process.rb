require 'lib/processes/abstract_process'

module Medusa
  class CreateCollectionProcess

    def self.process_definition
      Ruote.process_definition do
        sequence do
          create_fedora_collection
        end
      end
    end

  end
end