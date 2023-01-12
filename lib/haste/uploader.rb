require 'json'
require 'faraday'
require 'uri'

module Haste

  DEFAULT_SERVER_URL = 'https://new.hastebin.com'
  DEFAULT_SHARE_SERVER_URL = 'https://new.hastebin.com'

  class Uploader

    attr_reader :server_url, :server_token, :share_server_url, :server_user, :server_pass, :ssl_certs

    def initialize(server_url = nil, server_token = nil, share_server_url = nil, server_user = nil, server_pass = nil, ssl_certs = nil)
      @server_url = generate_url(server_url || Haste::DEFAULT_SERVER_URL)
      @share_server_url = generate_url(share_server_url || Haste::DEFAULT_SHARE_SERVER_URL)
      
      @server_user = server_user
      @server_token = server_token
      @server_pass = server_pass
      @ssl_certs   = ssl_certs
    end

    def generate_url(url)
      url = url.dup
      url = url.chop if url.end_with?('/')
      return url
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

    def post_path
      parsed_uri = URI.parse(server_url)
      "#{parsed_uri.path}/documents"
    end

    def do_post(data)
      connection.post(post_path, data)
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
      config.request :authorization, 'Bearer', @server_token if @server_token
      config.basic_auth(@server_user, @server_pass) if @server_user
      config.adapter Faraday.default_adapter
    end

    def fail_with(msg)
      raise Exception.new(msg)
    end

  end

end
