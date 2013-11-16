require 'json'
require 'net/http'
require 'net/https'
require 'uri'

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
      uri = URI.parse server
      http = Net::HTTP.new uri.host, uri.port
      if uri.scheme =~ /^https/
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response = http.post '/documents', @input
      if response.is_a?(Net::HTTPOK)
        data = JSON.parse(response.body)
        method = STDOUT.tty? ? :puts : :print
        STDOUT.send method, "#{server}/#{data['key']}"
      else
        abort "failure uploading: #{response.code}"
      end
    rescue JSON::ParserError => e
      abort "failure parsing response: #{e.message}"
    rescue Errno::ECONNREFUSED => e
      abort "failure connecting: #{e.message}"
    end

    private

    def server
      return @server if @server
      @server = (ENV['HASTE_SERVER'] || Haste::DEFAULT_URL).dup
      @server.chop! if server.end_with?('/')
      @server
    end

  end

end
