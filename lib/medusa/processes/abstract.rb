require File.join(File.dirname(__FILE__), '..', '..', 'medusa')

module Medusa
  module Process
    class Abstract
      #override this to return a Ruote process definition for this processes
      def self.process_definition
        raise RuntimeError, 'subclass responsibility'
      end
    end
  end
end