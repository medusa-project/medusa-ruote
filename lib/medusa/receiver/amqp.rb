#the standard RuoteAMQP::Receiver doesn't provide a direct way to deal with errors
#This provides one based on:
#https://groups.google.com/group/openwferu-users/browse_thread/thread/94c14677e68c8534
#https://gist.github.com/1171232
#In short, if there is an error in the AMQP participant then set workitem['fields']['__error__']
#When the receiver gets a workitem back it first checks this field and if it is not empty then
#it intercepts the usual action and creates an error instead. If not then it proceeds normally
require 'ruote-amqp'
module Medusa
  module Receiver

    class RemoteError < RuntimeError
      attr_accessor :fei

      def initialize(fei, error_message)
        self.fei = fei
        self.message = error_message
        super(self.message)
      end
    end

    class AMQP < RuoteAMQP::Receiver
      def receive(workitem)
        if error = workitem_error(workitem)
          @context.error_handler.action_handle('error', workitem['fei'],
                                               RemoteError.new(workitem['fei'], error))
        else
          super(workitem)
        end
      end

      protected

      def workitem_error(workitem)
        workitem['fields']['__error__']
      end

    end
  end
end