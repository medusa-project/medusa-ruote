require File.join(File.dirname(__FILE__), '..', '..', 'medusa')
module Medusa
  module Utils
    module Dir
      module_function

      #Return true if each file (recursively) under the given directory has not been modified
      #for <delay_time> seconds from when this function is called.
      #If there are no files under the directory return false.
      def directory_unmodified?(directory_name, delay_time)
        now = Time.now
        last = directory_last_modified(directory_name)
        return (last and (now - last > delay_time))
      end

      #Return the latest time a file under this directory (recursively) has been modified,
      #or nil if there are no files.
      def directory_last_modified(directory_name)
        last = nil
        Filescan.new(directory_name, true, false).each_file do |file, file_name|
          last ||= file.mtime
          last = [last, file.mtime].max
        end
        return last
      end

    end
  end
end