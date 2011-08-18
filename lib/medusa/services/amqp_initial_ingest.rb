require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'services/abstract_fedora_amqp'
require 'utils/luhn'
require 'uuid'
require 'bagit'
require 'utils/bag'

module Medusa
  module Service
    class AMQPInitialIngest < AbstractFedoraAMQP

      def service_name
        'amqp_initial_ingest_service'
      end

      def self.amqp_listen_queue
        'initial_ingest_service'
      end

      def process_workitem(workitem)
        with_parsed_workitem(workitem) do |h|
          begin
            #create at new bag
            bag = Medusa::Utils::Bag.extract_bag(h['fields']['dir'])

            #add uuid to workitem
            h['fields']['uuid'] = Medusa::Utils::Luhn.add_check_character(UUID.generate)

            #use bag to create fedora object of type Medusa::BasicImage using uuid
            bag_to_fedora_object(bag, h['fields']['uuid'], Medusa::BasicImage)

            #return modified workitem
            return h

            #TODO this should probably do something that will indicate to the engine that
            #the step failed. We need to research that some more - there may be an
            #idiomatic way to do it.
          rescue Medusa::Utils::InvalidBagError => e
            h['fields']['errors'] << "#{e.class}: #{e.message}"
            return h
            #TODO we should rescue other errors, say if making the fedora object fails
          rescue Exception => e
            h['fields']['errors'] << "#{e.class} #{e.message}"
            return h
          end
        end
      end

    end
  end
end

