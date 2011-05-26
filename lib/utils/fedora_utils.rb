#broadly useful methods for interacting with Fedora
require 'active-fedora'

module FedoraUtils

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

end
