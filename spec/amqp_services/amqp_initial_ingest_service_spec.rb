require File.dirname(__FILE__) + '/../spec_helper'
require 'lib/amqp_services/amqp_initial_ingest_service'

describe AMQPInitialIngestService do

  it { should be_a(AbstractAMQPService) }

  it "should listen to the initial_ingest_service queue" do
    AMQPInitialIngestService.amqp_listen_queue.should == 'initial_ingest_service'
  end

  it "should be be named amqp_initial_ingest_service" do
    AMQPInitialIngestService.new.service_name.should == 'amqp_initial_ingest_service'
  end


end
