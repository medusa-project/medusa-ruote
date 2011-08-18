#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'services/amqp_initial_ingest_service'

Medusa::AMQPInitialIngestService.new.start