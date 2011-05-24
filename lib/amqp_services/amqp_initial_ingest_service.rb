require 'lib/amqp_services/abstract_amqp_service'
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
      #add uuid to workitem
      #create fedora object
      #import available streams (How do we recognize the image?
      #By looking in the marc? Is the marc itself named via convention?)
      #return
    end
  end
end