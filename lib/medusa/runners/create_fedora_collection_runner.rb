#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'services/create_fedora_collection'

Medusa::Service::CreateFedoraCollection.new.start