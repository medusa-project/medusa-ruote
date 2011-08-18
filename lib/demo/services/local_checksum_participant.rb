require 'ruote'
require 'digest'

module Medusa
  class LocalChecksumParticipant
    include Ruote::LocalParticipant

    def consume(workitem)
      dir = workitem.fields['dir']
      puts "locally checksumming #{dir}"
      sums = Dir[File.join('processing', dir, '*')].collect do |f|
        nil if ['.', '..'].include?(f)
        next if File.directory?(f)
        puts "checksumming #{f}"
        File.open(f) do |file|
          [File.basename(f), Digest::MD5.hexdigest(file.read)]
        end
      end
      puts 'writing checksum file'
      File.open(File.join('processing', dir, 'md5sums'), 'w') do |md5_file|
        sums.compact.each do |row|
          filename, sum = row
          md5_file.puts("#{filename}\t\t#{sum}")
        end
      end
      reply_to_engine(workitem)
    end
  end
end