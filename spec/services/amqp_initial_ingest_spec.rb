require File.dirname(__FILE__) + '/../spec_helper'
require 'services/amqp_initial_ingest'

module Medusa
  module Service
    describe AMQPInitialIngest do

      it { should be_a(AbstractFedoraAMQP) }

      it "should listen to the initial_ingest_service queue" do
        AMQPInitialIngest.amqp_listen_queue.should == 'initial_ingest_service'
      end

      it "should be be named amqp_initial_ingest_service" do
        AMQPInitialIngest.new.service_name.should == 'amqp_initial_ingest_service'
      end

    end
  end
end