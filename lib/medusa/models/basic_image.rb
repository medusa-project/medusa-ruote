require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'active-fedora'
module Medusa

  class BasicImage < ActiveFedora::Base

    # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
    #has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata

    #has_metadata :name => "descMetadata", :type => Hydra::ModsImage

    #has_metadata :name => 'preservationMetadata', :type => Medusa::Premis

    # A place to put extra metadata values
    has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
      m.field 'collection', :string
      m.field 'depositor', :string
      m.field 'title', :string
    end

    def initialize(attrs={})
      super(attrs)
      #add_relationship(:has_model, "hydra-cModel:commonMetadata")
      #add_relationship(:has_model, "hydra-cModel:genericContent")
    end
  end
end