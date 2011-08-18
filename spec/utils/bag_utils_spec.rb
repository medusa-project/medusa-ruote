require File.dirname(__FILE__) + '/../spec_helper'
require 'utils/bag_utils'

module Medusa
  describe BagUtils do


    it "should be able to extract a bag from a directory" do
      bag = BagUtils.extract_bag(File.join(PROJECT_ROOT, 'test-items', 'bag0'))
      bag.valid?.should be_true
      bag.should be_a(BagIt::Bag)
    end

    it "should error if it tries to extract a bag from a directory that isn't a bag" do
      lambda { BagUtils.extract_bag(File.join(PROJECT_ROOT, 'test-items', 'bag-invalid')) }.should raise_error(InvalidBagError)
    end

  end
end
