require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'processes/abstract'

module Medusa
  module Process
    class CreateCollection < Abstract

      def self.process_definition
        Ruote.process_definition do
          sequence do
            create_fedora_collection
          end
        end
      end

    end
  end
end