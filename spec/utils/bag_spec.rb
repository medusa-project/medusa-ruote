require File.dirname(__FILE__) + '/../spec_helper'
require 'utils/bag'

module Medusa
  module Utils
    describe Bag do


      it "should be able to extract a bag from a directory" do
        bag = Bag.extract_bag(File.join(PROJECT_ROOT, 'test-items', 'bag0'))
        bag.valid?.should be_true
        bag.should be_a(BagIt::Bag)
      end

      it "should error if it tries to extract a bag from a directory that isn't a bag" do
        lambda { Bag.extract_bag(File.join(PROJECT_ROOT, 'test-items', 'bag-invalid')) }.should raise_error(InvalidBagError)
      end

    end
  end
end