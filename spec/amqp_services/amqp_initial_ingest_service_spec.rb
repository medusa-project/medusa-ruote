require File.dirname(__FILE__) + '/../spec_helper'
require 'lib/amqp_services/amqp_initial_ingest_service'

describe AMQPInitialIngestService do

  it { should be_a(AbstractFedoraAMQPService) }

  it "should listen to the initial_ingest_service queue" do
    AMQPInitialIngestService.amqp_listen_queue.should == 'initial_ingest_service'
  end

  it "should be be named amqp_initial_ingest_service" do
    AMQPInitialIngestService.new.service_name.should == 'amqp_initial_ingest_service'
  end

  describe "bag interaction" do
    before(:each) do
      @service = AMQPInitialIngestService.new
    end

    it "should be able to extract a bag from a directory" do
      bag = @service.extract_bag(File.join(PROJECT_ROOT, 'test-items', 'bag0'))
      bag.valid?.should be_true
      bag.should be_a(BagIt::Bag)
    end

    it "should error if it tries to extract a bag from a directory that isn't a bag" do
      lambda {@service.extract_bag(File.join(PROJECT_ROOT, 'test-items', 'bag-invalid'))}.should raise_error(InvalidBagError)
    end

  end
end
