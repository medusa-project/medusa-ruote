require 'ruote'

module Medusa
  class AbstractProcess
    #override this to return a Ruote process definition for this processes
    def self.process_definition
      raise RuntimeError, 'subclass responsibility'
    end
  end
end