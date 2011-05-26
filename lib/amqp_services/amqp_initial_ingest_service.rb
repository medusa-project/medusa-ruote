require 'lib/amqp_services/abstract_fedora_amqp_service'
require 'lib/utils/luhn'
require 'uuid'
require 'bagit'
require 'medusa'

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
      bag = Bag.new(h['fields']['dir'])

      #validate
      unless bag.valid?
        logger.error("Invalid bag at: #{h['fields']['dir']}")
        h['fields']['errors'] << "Invalid bag at: #{h['fields']['dir']}"
        return h
      end

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
          ds       = ActiveFedora::Datastream.new(:dsLabel => filename, :controlGroup => "M", :blob => File.open(f))
          item.add_datastream ds
        end
        item.save
      end

      #return modified workitem
      return h
    end
  end

end

