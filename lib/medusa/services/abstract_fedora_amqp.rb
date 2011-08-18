#Mixes in FedoraUtils to facilitate the common case of services that need to interact with Fedora
require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'services/abstract_amqp'
require 'utils/fedora'
require 'active-fedora'

module Medusa
  module Service
    class AbstractFedoraAMQP < AbstractAMQP
      include Medusa::Utils::Fedora

      def startup_actions
        super
        ENV['environment'] ||= 'development'
        ActiveFedora.init
      end

    end
  end
end