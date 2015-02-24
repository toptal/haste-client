require 'json'
require 'faraday'

module Haste

  DEFAULT_URL = 'http://hastebin.com'

  class Uploader

    attr_reader :server_url, :server_user, :server_pass

    def initialize(server_url = nil, server_user = nil, server_pass = nil)
      @server_url = server_url || Haste::DEFAULT_URL
      @server_url = @server_url.dup
      @server_url = @server_url.chop if @server_url.end_with?('/')
    end

    # Take in a path and return a key
    def upload_path(path)
      fail_with 'No input file given' unless path
      fail_with "#{path}: No such path" unless File.exists?(path)
      upload_raw open(path).read
    end

    # Take in data and return a key
    def upload_raw(data)
      data.rstrip!
      response = do_post data
      if response.status == 200
        data = JSON.parse(response.body)
        data['key']
      else
        fail_with "failure uploading: #{response.body}"
      end
    rescue JSON::ParserError => e
      fail_with "failure parsing response: #{e.message}"
    rescue Errno::ECONNREFUSED => e
      fail_with "failure connecting: #{e.message}"
    end

    private

    def do_post(data)
      connection.post('/documents', data)
    end

    def connection
      @connection ||= Faraday.new(:url => server_url) do |c|
        c.basic_auth(@server_user, @server_user) if @server_user
        c.adapter Faraday.default_adapter
      end
    end

    def fail_with(msg)
      raise Exception.new(msg)
    end

  end

end
