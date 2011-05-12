#!/usr/bin/env ruby
#listen on make_file_types queue
#return on ruote_workitems queue

require 'rubygems'
require 'bundler/setup'
require 'open3'
require 'abstract_amqp_service'

class AMQPWorker < AbstractAMQPService

  def service_name
    'amqp_worker'
  end

  def amqp_listen_queue
    'make_file_types'
  end

  def process_workitem(h)
    dir = h['fields']['dir']
    types = Dir[File.join('processing', dir, '*')].collect do |filename|
      nil if ['.', '..'].include?(filename)
      filetype = Open3.popen3('file', '-b', filename) do |stdin, stdout, stderr|
        stdout.read
      end
      #filetype = `file -b #{filename}`
      [File.basename(filename), filetype]
    end
    File.open(File.join('processing', dir, 'file_types'), 'w') do |f|
      self.logger.info "File info:"
      types.each do |file_info|
        name, type = *file_info
        output = "#{name}:\t#{type}"
        self.logger.info output
        f.puts(output)
      end
    end
    nil
  end

end
AMQPWorker.new.start
# The received workitem is just a json object which is a hash (the workitem) converted to JSON
# for example:
#{"participant_name":"make_file_types","fields":{"dir":"test-items","dispatched_at":"2011-05-11 17:16:42.915043 UTC","params":{"participant_options":{"forget":false,"queue":"make_file_types"},"ref":"make_file_types"}},"fei":{"wfid":"20110511-binotzujido","engine_id":"engine","expid":"0_0_2","subid":"13a7628bb33dbd68604cb511bafe60e3"}}
