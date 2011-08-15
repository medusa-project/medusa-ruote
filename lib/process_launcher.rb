#This will figure out what process to start for a bag and provide a way to start it.
require 'lib/engine'
class ProcessLauncher

  #Answer a Process if we know what to do with this bag, nil otherwise
  def process_for(bag)
    requested_process = bag.bag_info('Medusa-Process')
    case requested_process
      when 'create-collection'
        CreateCollectionProcess
      else
        nil
    end
  end

  #Process the bag - actually record the directory and start the process in the engine
  def process_bag(bag, bag_directory)
    if process = self.process_for(bag)
      MedusaEngine.instance.engine.launch(process.process_definition, :processing_dir => bag_directory)
    end
  end

end