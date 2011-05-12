require 'rubygems'
require 'bundler/setup'
require 'yajl'
require 'yajl/json_gem'
require 'log4r'
require 'bunny'
require 'mq'
require 'daemons'
require 'fileutils'

class AbstractAMQPService < Object

  attr_accessor :logger

  def start
    working_dir = Dir.getwd
    ensure_log_and_pid_dirs()
    Daemons.run_proc(self.process_name, :dir => self.pid_dir,
                     :log_dir => self.log_dir, :backtrace => true) do
      EventMachine.run do
        Dir.chdir working_dir
        start_logging()
        listen()
      end
    end
  end

  def ensure_log_and_pid_dirs
    [self.log_dir, self.pid_dir].each { |dir| FileUtils.mkdir_p(dir) }
  end

  def start_logging
    self.setup_logger
    self.logger.info "Started"
    Kernel.at_exit do
      self.logger.info "Stopped"
    end
  end

  def listen
    MQ.queue(self.amqp_listen_queue, :durable => true).subscribe do |workitem|
      self.reply_to_engine(process_workitem(workitem))
    end
  end

  def setup_logger
    self.logger = Log4r::Logger.new('log')
    outputter = Log4r::RollingFileOutputter.new('log', :filename => File.join('log', self.service_name),
                                                :maxtime => (3600 * 24), :max_backups => 6)
    self.logger.outputters = outputter
    outputter.formatter = Log4r::PatternFormatter.new(:pattern => "%d [%5l] %M")
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

  def log_dir
    'log'
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
    yield JSON.parse(workitem)
  end

  def canonicalize_return_workitem(workitem)
    workitem.is_a?(Hash) ? workitem.to_json : workitem
  end

end