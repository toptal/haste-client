require 'bundler/setup'
require 'json'
require 'uri'
require 'rest-client'

module Haste

  DEFAULT_URL = 'http://hastebin.com'

  class CLI

    # Pull all of the data from STDIN
    def initialize
      if STDIN.tty?
        file = ARGV.first
        abort 'No input file given' unless file
        abort "#{file}: No such path" unless File.exists?(file)
        @input = open(file).read
      else
        @input = STDIN.readlines.join
      end
      # clean up
      @input.rstrip!
    end

    # Upload the and output the URL we get back
    def start
      raw_data = RestClient.post "#{server}/documents", @input
      data = JSON.parse(raw_data)
      key = data['key']
      STDOUT.send (STDOUT.tty? ? :puts : :print), "#{server}/#{key}"
    rescue JSON::ParserError => e
      abort "failure parsing response: #{e.message}"
    rescue RestClient::Exception => e
      abort "failure uploading: #{e.message}"
    rescue Errno::ECONNREFUSED => e
      abort "failure connecting: #{e.message}"
    end

    private

    # Get the server address used
    def server
      return @server if @server
      @server = (ENV['HASTE_SERVER'] || Haste::DEFAULT_URL).dup
      @server.chop! if server.end_with?('/')
      @server
    end

  end

end
