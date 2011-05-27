require 'lib/amqp_services/abstract_fedora_amqp_service'
require 'lib/utils/luhn'
require 'uuid'
require 'bagit'
require 'medusa'

class InvalidBagError < RuntimeError;
end

class AMQPInitialIngestService < AbstractFedoraAMQPService

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
        bag = extract_bag(h['fields']['dir'])

        #add uuid to workitem
        h['fields']['uuid'] = Luhn.add_check_character(UUID.generate)

        #use bag to create fedora object of type Medusa::BasicImage using uuid
        bag_to_fedora_object(bag, h['fields']['uuid'], Medusa::BasicImage)

        #return modified workitem
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

  #create a Bag, throwing an exception if there is a problem with the incoming package
  def extract_bag(dir)
    bag = BagIt::Bag.new(dir)
    unless bag.valid?
      message = "Invalid bag at: #{dir}"
      logger.error(message)
      raise InvalidBagError, message
    end
    return bag
  end

end

