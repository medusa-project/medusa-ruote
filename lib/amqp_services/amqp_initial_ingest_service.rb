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

      #create at new bag
      bag = extract_bag(h['fields']['dir'])

      #generate uuid for object
      uuid = Luhn.add_check_character(UUID.generate)

      #add uuid to workitem
      h['fields']['uuid'] = uuid

      #create fedora object using uuid
      replacing_object(uuid) do
        item = Medusa::BasicImage.new(:pid => uuid)

        #add datastreams from the bag
        bag.bag_files.each do |f|
          filename = File.basename(f)
          ds = ActiveFedora::Datastream.new(:dsLabel => filename, :controlGroup => "M", :blob => File.open(f))
          item.add_datastream ds
        end
        item.save
      end

      #return modified workitem
      return h

      #TODO this should probably do something that will indicate to the engine that
      #the step failed. We need to research that some more - there may be an
      #idiomatic way to do it.
      rescue InvalidBagError => e
      h['fields']['errors'] << "#{e.class}: #{e.message}"
      return h
    end
  end

  #create a Bag, throwing an exception if there is a problem with the incoming package
  def extract_bag(dir)
    bag = Bag.new(dir)
    unless bag.valid?
      message = "Invalid bag at: #{dir}"
      logger.error(message)
      raise InvalidBagError, message
    end
    return bag
  end


end

