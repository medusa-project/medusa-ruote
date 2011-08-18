require File.dirname(__FILE__) + '/../spec_helper'
require 'utils/luhn'

#note that the uuids used here are some that Tom Habing generated, so that provides a bit of independent confirmation

module Medusa
  module Utils
    describe Luhn do

      it "should return the correct checkdigit for a uuid" do
        Luhn.check_character('f7236f68-5c00-4837-a7a0-af387823de45').should == '4'
      end

      it "should be able to append a check digit for a uuid" do
        Luhn.add_check_character('7a72ce75-26f1-4c71-9fc6-c00d90c4ab70').should == '7a72ce75-26f1-4c71-9fc6-c00d90c4ab70-e'
      end

      it "should verify a uuid with a good check digit" do
        Luhn.verify('f7236f68-5c00-4837-a7a0-af387823de45-4').should be_true
      end

      it "should not verify a uuid with a bad check digit" do
        Luhn.verify('7a72ce75-26f1-4c71-9fc6-c00d90c4ab70-f').should be_false
      end

    end
  end
end