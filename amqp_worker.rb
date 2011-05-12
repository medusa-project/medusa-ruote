#!/usr/bin/env ruby
#listen on make_file_types queue
#return on ruote_workitems queue

require 'rubygems'
require 'bundler/setup'
require 'mq'
require 'bunny'
require 'yajl'
require 'yajl/json_gem'
require 'open3'
require 'daemons'
require 'log4r'
require 'fileutils'

working_dir = Dir.getwd
FileUtils.mkdir_p('log')
FileUtils.mkdir_p('pid')
Daemons.run_proc('amqp_worker.rb', :dir => 'pid', :log_dir => 'log', :backtrace => true) do
  EventMachine.run do
    Dir.chdir working_dir
    logger = Log4r::Logger.new('log')
    logger.outputters = outputter = Log4r::RollingFileOutputter.new('log', :filename => 'log/amqp-worker', :maxtime => (3600 * 24), :max_backups => 6)
    outputter.formatter = Log4r::PatternFormatter.new(:pattern => "%d [%5l] %M")
    logger.info "Started"
    MQ.queue('make_file_types', :durable => true).subscribe do |workitem|
      h = JSON.parse(workitem)
      logger.info "Received workitem #{workitem}:"
      logger.info JSON::pretty_generate(h)
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
        logger.info "File info:"
        types.each do |file_info|
          name, type = *file_info
          output = "#{name}:\t#{type}"
          logger.info output
          f.puts(output)
        end
      end
      bunny = Bunny.new
      bunny.start
      return_queue = bunny.queue('ruote_workitems', :durable => true)
      return_queue.publish(workitem, :persistent => true)
    end
    Kernel.at_exit do
      logger.info "Stopped"
    end
  end
end
# The received workitem is just a json object which is a hash (the workitem) converted to JSON
# for example:
#{"participant_name":"make_file_types","fields":{"dir":"test-items","dispatched_at":"2011-05-11 17:16:42.915043 UTC","params":{"participant_options":{"forget":false,"queue":"make_file_types"},"ref":"make_file_types"}},"fei":{"wfid":"20110511-binotzujido","engine_id":"engine","expid":"0_0_2","subid":"13a7628bb33dbd68604cb511bafe60e3"}}
