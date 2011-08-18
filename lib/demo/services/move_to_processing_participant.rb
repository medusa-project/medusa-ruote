require 'ruote'

module Medusa
  class MoveToProcessingParticipant
    include Ruote::LocalParticipant

    def consume(workitem)
      dir = workitem.fields['dir']
      puts "moving to processing #{dir}"
      FileUtils.mv(File.join('in', "#{dir}_ready"), File.join('processing', dir))
      reply_to_engine(workitem)
    end
  end
end