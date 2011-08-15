#This will figure out what process to start for a bag and provide a way to start it.
require 'lib/engine'
class ProcessLauncher

  #Answer a Process if we know what to do with this bag, nil otherwise
  def process_for(bag)

  end

  #Process the bag - actually record the directory and start the process in the engine
  def process_bag(bag, bag_directory)
    MedusaEngine.instance.engine.launch(self.process_for(bag), :processing_dir => bag_directory)
  end

end