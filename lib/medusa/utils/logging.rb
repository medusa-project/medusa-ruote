#because of the way this is used (with daemons) we need to set up a dummy logger
#on stdout when the daemon class is initialized and then hook up the real logger
#via start_logging after daemonization.
require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
require 'log4r'

module Medusa
  module Utils
    module Logging
      attr_accessor :logger

      def start_stdout_logger
        self.logger = Log4r::Logger.new 'stdout'
        self.logger.outputters = Log4r::Outputter.stdout
      end

      def start_logging(log_name)
        ensure_log_dir
        self.setup_logger(log_name)
        self.logger.info "Started"
        Kernel.at_exit do
          self.logger.info "Stopped"
        end
      end

      def setup_logger(log_name)
        self.logger = Log4r::Logger.new('log')
        outputter = Log4r::RollingFileOutputter.new('log', :filename => File.join('log', log_name),
                                                    :maxtime => (3600 * 24), :max_backups => 6)
        self.logger.outputters = outputter
        outputter.formatter = Log4r::PatternFormatter.new(:pattern => "%d [%5l] %M")
      end

      def ensure_log_dir()
        FileUtils.mkdir_p(self.log_dir)
      end

      def log_dir
        'log'
      end

    end
  end
end