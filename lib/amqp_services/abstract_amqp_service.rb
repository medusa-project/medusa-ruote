require 'rubygems'
require 'bundler/setup'
require 'yajl'
require 'yajl/json_gem'
require 'bunny'
require 'mq'
require 'daemons'
require 'fileutils'
require 'lib/utils/fedora_utils'
require 'lib/utils/logging'

class AbstractAMQPService < Object
  include Logging

  def initialize(params = {})
    #this is a bit kludgy, but until the service actually starts up use a stdout logger
    #may be useful for testing
    start_stdout_logger
  end

  def start
    working_dir = Dir.getwd
    ensure_pid_dir
    ensure_log_dir
    Daemons.run_proc(self.process_name, :dir => self.pid_dir,
                     :log_dir => self.log_dir, :backtrace => true) do
      EventMachine.run do
        Dir.chdir working_dir
        startup_actions
        logger.info("Listening")
        Kernel.at_exit do
          logger.info("Shutting down")
        end
        listen()
      end
    end
  end

  #override to do additional things after daemonizing but before the server
  #starts listening
  def startup_actions
    start_logging(self.service_name)
  end

  def ensure_pid_dir
    FileUtils.mkdir_p(self.pid_dir)
  end

  def listen
    MQ.queue(self.amqp_listen_queue, :durable => true).subscribe do |workitem|
      self.reply_to_engine(process_workitem(workitem))
    end
  end

  def service_name
    raise RuntimeError, 'Subclass responsibility'
  end

  def self.amqp_listen_queue
    raise RuntimeError, "Subclass responsibility"
  end

  def amqp_listen_queue
    self.class.amqp_listen_queue
  end

  def process_name
    "#{self.service_name}.rb"
  end

  def pid_dir
    'pid'
  end

  #Override in subclasses to do the work for each message received.
  #Receives the workitem. Use with_parsed_workitem to get a Ruby hash.
  #Should return either:
  #false - in this case the original workitem is sent back
  #a hash - in this case the hash is converted to JSON and sent back
  #a JSON string - in this case the string is sent back as is
  def process_workitem(h)
    h
  end

  def amqp_return_queue
    'ruote_workitems'
  end

  #Take the workitem (as a hash or a JSON string) and return it to
  #the workflow engine
  def reply_to_engine(workitem)
    bunny = Bunny.new
    bunny.start
    return_queue = bunny.queue(self.amqp_return_queue, :durable => true)
    return_queue.publish(canonicalize_return_workitem(workitem),
                         :persistent => true)
  end

  def with_parsed_workitem(workitem)
    if workitem.is_a?(Hash)
      yield workitem
    else
      yield JSON.parse(workitem)
    end
  end

  def canonicalize_return_workitem(workitem)
    workitem.is_a?(Hash) ? workitem.to_json : workitem
  end

  def add_error_to_workitem(hash, error_string)
    hash['fields']['errors'] ||= []
    hash['fields']['errors'] << error_string
  end

end