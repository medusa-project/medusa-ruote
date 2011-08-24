require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'services/abstract_fedora_amqp'
require 'utils/luhn'
require 'uuid'
require 'models/basic_collection'
require 'utils/bag'

module Medusa
  module Service
    class CreateFedoraCollection < AbstractFedoraAMQP

      def service_name
        'create_fedora_collection'
      end

      def self.amqp_listen_queue
        'create_fedora_collection'
      end

      def process_workitem(workitem)
        with_parsed_workitem(workitem) do |h|
          begin
            logger.info("Starting collection creation")
            #get bag representing collection
            logger.info("Extracting bag from #{h['fields']['processing_dir']}")
            bag = Medusa::Utils::Bag.extract_bag(h['fields']['processing_dir'])
            logger.info("Extracted bag from #{h['fields']['processing_dir']}")
            uuid = Medusa::Utils::Luhn.add_check_character(UUID.generate)

            #Each content file is assumed to be a metadata file for the bag
            fedora_object = bag_to_fedora_object(bag, "medusa:#{uuid}", Medusa::BasicCollection)

            #The bag metadata may have information pertaining to the collection to be
            #added to the object. If we set Medusa::BasicCollection up for it.

            logger.info("Created collection with uuid: #{uuid} with pid: #{fedora_object.pid}")
            h['fields']['uuid'] = uuid

            return h

            #TODO - regarding below see comments on add_error_to_workitem - how does Ruote really want errors
            #to be reported?
            #TODO this should probably do something that will indicate to the engine that
            #the step failed. We need to research that some more - there may be an
            #idiomatic way to do it.
            #rescue InvalidBagError => e
            #  add_error_to_workitem(h, "#{e.class}: #{e.message}")
            #  return h
            #  #TODO we should rescue other errors, say if making the fedora object fails
            #rescue Exception => e
            #  add_error_to_workitem(h, "#{e.class}: #{e.message}")
            #  return h
          end
        end
      end

    end
  end
end