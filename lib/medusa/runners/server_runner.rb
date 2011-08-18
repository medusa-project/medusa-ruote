#!/usr/bin/env ruby
#the daemons argument will be passed through, so call like:
#script/server_runner.rb <start | stop | restart | ...>
require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'server'

Medusa::MedusaServer.new.start

