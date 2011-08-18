require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'active-fedora'

module Medusa
  module Model

    class BasicCollection < ActiveFedora::Base

      # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
      #has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata

      #has_metadata :name => 'descMetadata', :type => Hydra::ModsImage

      # A place to put extra metadata values
      has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
        #m.field 'description', :string
      end

      def initialize(attrs={})
        super(attrs)
        #add_relationship(:has_model, "hydra-cModel:commonMetadata")
      end

    end
  end
end