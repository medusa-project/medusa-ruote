require 'rubygems'
require 'bundler/setup'
require 'open3'
require 'lib/amqp_services/abstract_amqp_service'

module Medusa
  class AMQPFileTypeService < AbstractAMQPService

    def service_name
      'amqp_file_type_service'
    end

    def self.amqp_listen_queue
      'file_type_service'
    end

    def process_workitem(workitem)
      with_parsed_workitem(workitem) do |h|
        logger.info("Processing wfid: #{h['fei']['wfid']}")
        dir = h['fields']['dir']
        types = Dir[File.join('processing', dir, '*')].collect do |filename|
          nil if ['.', '..'].include?(filename)
          filetype = Open3.popen3('file', '-b', filename) do |stdin, stdout, stderr|
            stdout.read
          end
          [File.basename(filename), filetype]
        end
        File.open(File.join('processing', dir, 'file_types'), 'w') do |f|
          types.each do |file_info|
            name, type = *file_info
            output = "#{name}:\t#{type}"
            f.puts(output)
          end
        end
        return workitem
      end
    end

  end
end
