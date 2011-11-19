require 'restclient'
require 'json'

module Haste

  DEFAULT_URL = 'http://localhost:7777'

  class CLI

    attr_reader :input

    # Pull all of the data from STDIN
    def initialize
      @input = STDIN.readlines.join
      @input.strip!
    end

    # Upload the and output the URL we get back
    def start
      json = RestClient.post "#{server}/documents", input
      data = JSON.parse(json)
      puts "#{server}/#{data['key']}"
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
