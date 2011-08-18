require File.dirname(__FILE__) + '/../spec_helper'
require 'lib/utils/fedora_utils'
require 'bagit'

module Medusa
  class FedoraUtilsTester
    include FedoraUtils
  end

  describe FedoraUtils do

    before(:each) do
      @tester = FedoraUtilsTester.new
    end

    it "provides a convenience method for executing a block while first deleting a given fedora object" do
      @tester.should respond_to(:replacing_object)
      pid = 'spec:replacing_object'
      ActiveFedora::Base.find(pid).should be_false
      object = ActiveFedora::Base.new(:pid => pid).save
      ActiveFedora::Base.find(pid).should be_true
      @tester.replacing_object(pid) do
        #don't have to do anything - the object should disapper
      end
      ActiveFedora::Base.find(pid).should be_false
    end

    it "provides a method for ingesting content from a bag into a single fedora object" do
      @tester.should respond_to(:bag_to_fedora_object)
      uuid = 'spec:bag_to_fedora_object'
      bag = BagIt::Bag.new(File.join(PROJECT_ROOT, 'test-items', 'bag0'))
      @tester.bag_to_fedora_object(bag, uuid, ActiveFedora::Base)
      object = ActiveFedora::Base.find(uuid)
      object.should_not be_nil
      object.file_streams.collect { |stream| stream.label }.to_set.should == ['marc.xml', 'afm0000092.jp2'].to_set
    end

  end
end