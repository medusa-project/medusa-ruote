require 'lib/amqp_services/abstract_amqp_service'
require 'lib/utils/luhn'
require 'uuid'
require 'active-fedora'

class AMQPInitialIngestService < AbstractAMQPService

  def service_name
    'amqp_initial_ingest_service'
  end

  def self.amqp_listen_queue
    'initial_ingest_service'
  end

  def process_workitem(workitem)
    with_parsed_workitem(workitem) do |h|
      #generate uuid for object
      uuid = Luhn.add_check_character(UUID.generate)
      #add uuid to workitem
      h['fields']['uuid'] = uuid
      #create fedora object using uuid

      #import available streams (How do we recognize the image?
      #By looking in the marc? Is the marc itself named via convention?)
      #for now perhaps do something very simple
      #note that presumably we got the object directory in the workitem, so we can
      #actually find it.
      
      #return modified workitem
      return h
    end
  end
end