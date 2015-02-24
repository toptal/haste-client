require 'json'
require 'faraday'

module Haste

  DEFAULT_URL = 'http://hastebin.com'

  class Uploader

    attr_reader :server_url, :server_user, :server_pass, :ssl_certs

    def initialize(server_url = nil, server_user = nil, server_pass = nil, ssl_certs = nil)
      @server_url = server_url || Haste::DEFAULT_URL
      @server_url = @server_url.dup
      @server_url = @server_url.chop if @server_url.end_with?('/')

      @server_user = server_user
      @server_pass = server_pass
      @ssl_certs   = ssl_certs
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
      @connection ||= connection_set
    end

    def connection_set
      return connection_https if @ssl_certs
      connection_http
    end

    def connection_http
      Faraday.new(:url => server_url) do |c|
        connection_config(c)
      end
    end

    def connection_https
      Faraday.new(:url => server_url, :ssl => { :ca_path => @ssl_certs }) do |c|
        connection_config(c)
      end
    end

    def connection_config(config)
      config.basic_auth(@server_user, @server_pass) if @server_user
      config.adapter Faraday.default_adapter
    end

    def fail_with(msg)
      raise Exception.new(msg)
    end

  end

end
