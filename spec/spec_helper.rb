#This file is for code to help conduct spec tests
require 'rspec'
require 'active-fedora'
require 'set'

#Add root directory to load path
PROJECT_ROOT =  File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift PROJECT_ROOT
require 'lib/medusa'

#initialize Active Fedora test environment
ENV['environment'] = 'test'
ActiveFedora.init

RSpec.configure do |config|
  #make sure all objects are cleared out of Fedora before each test
  #TODO It's possible that this is too extreme - evaluate later.
  config.before(:each) do
    ActiveFedora::Base.find(:all).each {|object| object.delete}
  end

end
