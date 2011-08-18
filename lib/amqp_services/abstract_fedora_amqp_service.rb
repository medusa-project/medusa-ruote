#Mixes in FedoraUtils to facilitate the common case of services that need to interact with Fedora
require 'lib/amqp_services/abstract_amqp_service'
require 'lib/utils/fedora_utils'
require 'active-fedora'

module Medusa
  class AbstractFedoraAMQPService < AbstractAMQPService
    include FedoraUtils

    def startup_actions
      super
      ENV['environment'] ||= 'development'
      ActiveFedora.init
    end

  end
end