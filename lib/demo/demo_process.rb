require File.join(File.dirname(__FILE__), '..', 'medusa')

module Medusa

  class DemoProcess
    def self.process
      Ruote.process_definition do
        sequence do
          move_to_processing
          make_checksums
          make_file_types
          move_to_out
        end
      end
    end
  end

end