require 'timeout'
Around('@use-demo-servers-with-timeout') do |scenario, block|
  Dir.chdir(PROJECT_ROOT)
  system('./start-demo.sh > /dev/null')
  Timeout.timeout(30) do
    block.call
  end
  Dir.chdir(PROJECT_ROOT)
  system('./stop-demo.sh > /dev/null')
end