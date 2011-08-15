require 'lib/amqp_services/abstract_fedora_amqp_service'
require 'lib/utils/luhn'
require 'uuid'
require 'lib/medusa/basic_collection'

class CreateFedoraCollection < AbstractFedoraAMQPService
  def service_name
    'create_fedora_collection'
  end

  def self.amqp_listen_queue
    'create_fedora_collection'
  end

  def process_workitem(workitem)
    with_parsed_workitem(workitem) do |h|
      begin
        #get bag representing collection
        bag = BagUtils.extract_bag(h['fields']['processing_dir'])
        uuid = Luhn.add_check_character(UUID.generate)

        #Each content file is assumed to be a metadata file for the bag
        fedora_object = bag_to_fedora_object(bag, uuid, Medusa::BasicCollection)

        #The bag metadata may have information pertaining to the collection to be
        #added to the object. If we set Medusa::BasicCollection up for it.

        logger.info("Created collection with uuid: #{uuid} with pid: #{fedora_object.pid}")
        h['fields']['uuid'] = uuid

        return h

        #TODO this should probably do something that will indicate to the engine that
        #the step failed. We need to research that some more - there may be an
        #idiomatic way to do it.
      rescue InvalidBagError => e
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