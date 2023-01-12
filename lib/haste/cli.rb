module Haste

  class CLI

    # Create a new uploader
    def initialize
      @uploader = Uploader.new(
        ENV['HASTE_SERVER'],
        ENV['HASTE_SERVER_TOKEN'],
        ENV['HASTE_SHARE_SERVER'],
        ENV['HASTE_USER'],
        ENV['HASTE_PASS'],
        ENV['HASTE_SSL_CERTS'])
    end

    # And then handle the basic usage
    def start
      # Take data in
      if STDIN.tty?
        key = @uploader.upload_path ARGV.first
      else
        key = @uploader.upload_raw STDIN.readlines.join
      end
      # Put together a URL
      url = "#{@uploader.share_server_url}/share/#{key}"
      # And write data out
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
