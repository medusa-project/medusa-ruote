require File.join(File.dirname(__FILE__), '..', '..', 'medusa')

module Medusa
  class MoveToOutParticipant
    include Ruote::LocalParticipant

    def consume(workitem)
      dir = workitem.fields['dir']
      puts "moving to out #{dir}"
      FileUtils.mv(File.join('processing', dir), File.join('out', dir))
      reply_to_engine(workitem)
    end
  end
end