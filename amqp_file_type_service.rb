require 'rubygems'
require 'bundler/setup'
require 'open3'
require 'abstract_amqp_service'

class AMQPFileTypeService < AbstractAMQPService

  def service_name
    'amqp_file_type_service'
  end

  def self.amqp_listen_queue
    'file_type_service'
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
