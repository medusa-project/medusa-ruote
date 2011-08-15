#Mixes in FedoraUtils to facilitate the common case of services that need to interact with Fedora
require 'lib/amqp_services/abstract_amqp_service'
require 'lib/utils/fedora_utils'
require 'active-fedora'

class AbstractFedoraAMQPService < AbstractAMQPService
  include FedoraUtils

  def startup_actions
    super
    ActiveFedora.init
  end

end