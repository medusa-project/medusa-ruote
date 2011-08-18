#!/usr/bin/env ruby
require 'lib/services/amqp_initial_ingest_service'

Medusa::AMQPInitialIngestService.new.start