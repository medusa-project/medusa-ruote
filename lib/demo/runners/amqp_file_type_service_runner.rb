#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'demo/services/amqp_file_type_service'

Medusa::AMQPFileTypeService.new.start