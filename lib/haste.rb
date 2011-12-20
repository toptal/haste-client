require 'json'
require 'net/http'
require 'uri'

module Haste

  DEFAULT_URL = 'http://hastebin.com'

  class CLI

    attr_reader :input

    # Pull all of the data from STDIN
    def initialize
      @input = STDIN.readlines.join
      @input.strip!
    end

    # Upload the and output the URL we get back
    def start
      uri = URI.parse server
      http = Net::HTTP.new uri.host, uri.port
      response = http.post '/documents', input
      if response.is_a?(Net::HTTPOK)
        data = JSON.parse(response.body)
        STDOUT.puts "#{server}/#{data['key']}"
      else
        STDERR.puts "failure uploading: #{response.code}"
      end
    rescue RuntimeError, JSON::ParserError => e
      STDERR.puts "failure uploading: #{response.code}"
    rescue Errno::ECONNREFUSED => e
      STDERR.puts "failure connecting: #{e.message}"
    end

    private

    def server
      return @server if @server
      @server = ENV['HASTE_SERVER'] || Haste::DEFAULT_URL
      @server.chop! if server.end_with?('/')
      @server
    end

  end

end
