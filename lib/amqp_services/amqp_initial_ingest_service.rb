require 'lib/amqp_services/abstract_amqp_service'
require 'uuid'
require 'active-fedora'
require 'bagit'

class AMQPInitialIngestService < AbstractAMQPService

  def service_name
    'amqp_initial_ingest_service'
  end

  def self.amqp_listen_queue
    'initial_ingest_service'
  end

  def process_workitem(workitem)
    with_parsed_workitem(workitem) do |h|

      #create at new bag
      bag = Bag.new(h['fields']['dir'])

      #validate
      unless bag.valid?
        logger.error("Invalid bag at: #{h['fields']['dir']}")
        h['fields']['errors'] << "Invalid bag at: #{h['fields']['dir']}"
        return h
      end

      #generate uuid for object
      uuid = UUID.generate
      #add uuid to workitem
      h['fields']['uuid'] = uuid
      #create fedora object using uuid

      dir   = h['fields']['dir']
      Medusa::Ingestor.new(dir,uuid).create_item


      #import available streams (How do we recognize the image?
      #By looking in the marc? Is the marc itself named via convention?)
      #for now perhaps do something very simple
      #note that presumably we got the object directory in the workitem, so we can
      #actually find it.

      #return modified workitem
      return h
    end
  end
end

require 'om'
require 'lib/utils/uuid.rb'

class Medusa::Ingestor

  def initialize(dir_path, pid)
    @dir = dir_path
    @pid = pid
  end

  # Creates a new item in Fedora
  #
  # @return [Medusa::BasicImage] the item object
  def create_item
    replacing_object(@pid) do
      #create collection, attach streams, return collection
      item                                            = Medusa::BasicImage.new(:pid => @pid)
      #open the premis and get the mods filename
      root_metadata_filename                  = premis_ds.root_metadata_file
      mods_xml                                = package_file_xml(item_path, root_metadata_filename)
      mods_ds = item.datastreams['descMetadata']
      mods_ds.ng_xml = mods_xml
      mods_ds.label = "MODS"
      title = mods_ds.term_values(:title_info)
      item.label = title
      #derivation files
      premis_ds.derivation_source_file_array.each_with_index do |deriv_file, i|
        ds_id = "DERIVATION#{i}"
        ds_path = package_file(item_path, deriv_file)
        deriv_ds = ActiveFedora::Datastream.new(:dsId => ds_id, :dsLabel => deriv_file, :controlGroup => "M", :blob => File.open(ds_path))
        item.add_datastream deriv_ds
      end

      #rigths metadata

      #content
      pm_filename = item.datastreams['preservationMetadata'].production_master_file
      pm_path = package_file(item_path, pm_filename)
      pm_ds = ActiveFedora::Datastream.new(:dsId => "PRODUCTION_MASTER", :dsLabel => pm_filename, :controlGroup => "M", :blob => File.open(pm_path))
      item.add_datastream pm_ds

      item.save
      item
    end
  end

  protected

  def package_file(*args)
    File.join(package_path, *args)
  end

  def package_file_contents(*args)
    File.read(package_file(*args))
  end

  def package_file_xml(*args)
    Nokogiri::XML::Document.parse(package_file_contents(*args))
  end

  def get_handle(premis_xml)
    ids = premis_xml.css("premis > object > objectIdentifier")
    id  = ids.detect { |id| id.css('objectIdentifierType').text == 'HANDLE' }
    id.css('objectIdentifierValue').text
  end

  def handle_to_pid(handle)
    handle.gsub(/^(.*?)\//, '')
  end

  #If there is an object with the given pid delete it and yield to the block.
  #For making this repeatable without hassle.
  def replacing_object(pid)
    begin
      object = ActiveFedora::Base.find(pid)
      object.delete unless object.nil?
    rescue ActiveFedora::ObjectNotFoundError
      #nothing
    end
    yield
  end

end

