#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'services/amqp_initial_ingest'

Medusa::Service::AMQPInitialIngest.new.start