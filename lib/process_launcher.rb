#This will figure out what process to start for a bag and provide a way to start it.
require 'lib/engine'
require 'lib/processes/create_collection_process'
require 'lib/utils/bag_utils'

module Medusa
  class ProcessLauncher
    #Answer a Process if we know what to do with this bag, nil otherwise
    def process_for(bag)
      requested_process = bag.bag_info['Medusa-Process']
      case requested_process
        when 'create-collection'
          CreateCollectionProcess
        else
          nil
      end
    end

    #Process the bag - actually record the directory and start the process in the engine
    def process_bag(bag_directory)
      if process = self.process_for(BagUtils.extract_bag(bag_directory))
        MedusaEngine.instance.engine.launch(process.process_definition, :processing_dir => bag_directory)
      end
    end

  end
end