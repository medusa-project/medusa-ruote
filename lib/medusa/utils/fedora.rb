#broadly useful methods for interacting with Fedora
require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'active-fedora'

module Medusa
  module Utils
    module Fedora

      #If there is an object with the given pid delete it and yield to the block.
      #For making this repeatable without hassle.
      #
      #@param [String] pid Fedora object identifier
      def replacing_object(pid)
        begin
          object = ActiveFedora::Base.find(pid)
          object.delete unless object.nil?
        rescue ActiveFedora::ObjectNotFoundError
          #nothing
        end
        yield
      end

      #add each data file in the bag to a fedora object with the given uuid and ActiveFedora::Base subclass
      #return the resulting ActiveFedora object
      def bag_to_fedora_object(bag, uuid, fedora_class)
        replacing_object(uuid) do
          item = fedora_class.new(:pid => uuid)

          #add datastreams from the bag
          bag.bag_files.each do |f|
            filename = File.basename(f)
            ds = ActiveFedora::Datastream.new(:dsLabel => filename, :controlGroup => "M")
            ds.content = File.open(f).read
            item.add_datastream(ds)
          end
          item.save
          return item
        end
      end

    end
  end
end