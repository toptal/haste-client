module Haste

  class CLI

    # Create a new uploader
    def initialize
      @uploader = Uploader.new ENV['HASTE_SERVER']
    end

    # And then handle the basic usage
    def start
      # Take data in
      key = if STDIN.tty?
        @uploader.upload_path ARGV.first
      else
        @uploader.upload_raw STDIN.readlines.join
      end
      # And write data out
      url = "#{@uploader.server_url}/#{key}"
      if STDOUT.tty?
        STDOUT.puts url
      else
        STDOUT.print url
      end
    rescue Exception => e
      abort e.message
    end

  end

end
