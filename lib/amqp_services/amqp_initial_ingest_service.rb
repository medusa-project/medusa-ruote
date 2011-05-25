require 'lib/amqp_services/abstract_amqp_service'
require 'uuid'
require 'active-fedora'
require 'bagit'
require 'medusa'

class AMQPInitialIngestService < AbstractAMQPService

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
      uuid = UUID.generate

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

  #If there is an object with the given pid delete it and yield to the block.
  #For making this repeatable without hassle.
  #
  #@param [String] pid Fedora object identifier
  def replacing_object(pid)
    begin
      object = ActiveFedora::Base.find(pid)
      object.delete unless object.nil?
    rescue ActiveFedora::ObjectNotFoundError
      #nothing
    end
    yield
  end

end

