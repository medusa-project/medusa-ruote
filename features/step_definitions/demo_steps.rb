require 'fileutils'

Given /^I give the demo servers time to start up$/ do
  sleep 10
end

When /^I move demo file folder into the in directory and rename it$/ do
  in_dir = File.join(PROJECT_ROOT, 'in')
  raise(RuntimeError, "in directory not present") unless File.directory?(in_dir)
  FileUtils.cp_r(File.join(PROJECT_ROOT, 'test-items', 'bag0', 'data'), in_dir)
  FileUtils.mv(File.join(in_dir, 'data'), File.join(in_dir, 'data_ready'))
end

#note that this will happily run forever, so make sure something is putting a timeout around it
Then /^I should see the processed files in the out directory$/ do
  processed = false
  loop do
    if demo_processed
      processed = true
      break
    end
    sleep 1
  end
  processed.should be_true
end

def demo_processed
  result_dir = File.join(PROJECT_ROOT, 'out', 'data')
  File.directory?(result_dir) and
      File.exists?(File.join(result_dir, 'md5sums')) and
      File.exists?(File.join(result_dir, 'file_types'))
end