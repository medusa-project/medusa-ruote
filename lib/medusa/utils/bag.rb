require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'bagit'

module Medusa
  module Utils

    class InvalidBagError < RuntimeError;
    end

    module Bag
      module_function

      #create a Bag, throwing an exception if there is a problem with the incoming package
      def extract_bag(dir)
        bag = BagIt::Bag.new(dir)
        unless bag.valid?
          message = "Invalid bag at: #{dir}"
          logger.error(message)
          raise InvalidBagError, message
        end
        return bag
      end

    end
  end

end

