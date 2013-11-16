module Haste

  DEFAULT_URL = 'http://hastebin.com'

  class Uploader

    attr_reader :server_url

    def initialize(server_url = nil)
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
      raw_data = RestClient.post "#{self.server_url}/documents", data
      data = JSON.parse(raw_data)
      data['key']
    rescue JSON::ParserError => e
      fail_with "failure parsing response: #{e.message}"
    rescue RestClient::Exception => e
      fail_with "failure uploading: #{e.message}"
    rescue Errno::ECONNREFUSED => e
      fail_with "failure connecting: #{e.message}"
    end

    private

    def fail_with(msg)
      raise Exception.new(msg)
    end

  end

end
