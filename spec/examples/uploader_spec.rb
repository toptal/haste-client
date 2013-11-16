require 'spec_helper'

describe Haste::Uploader do

  let(:uploader) { base.nil? ? Haste::Uploader.new : Haste::Uploader.new(base) }

  describe :upload_raw do

    let(:data) { 'hello world' }
    let(:url) { "#{uploader.server_url}/documents" }
    let(:base) { nil }
    let(:error_message) do
      begin
        @key = uploader.upload_raw data
        nil # nil otherwise
      rescue Haste::Exception => e
        e.message
      end
    end

    context 'with a good response' do

      let(:json) { '{"key":"hello"}' }

      before do
        RestClient.should_receive(:post).with(url, data).and_return(json)
      end

      it 'should get the key' do
        error_message.should be_nil # no error
        @key.should == 'hello'
      end

    end

    context 'with a bad json response' do

      let(:json) { '{that:not_even_json}' }

      before do
        RestClient.should_receive(:post).with(url, data).and_return(json)
      end

      it 'should get an error' do
        error_message.should start_with 'failure parsing response: '
      end

    end

    context 'with a 404 response' do

      before do
        error = RestClient::ResourceNotFound.new
        RestClient.should_receive(:post).with(url, data).and_raise(error)
      end

      it 'should get an error' do
        error_message.should == 'failure uploading: Resource Not Found'
      end

    end

    context 'with a non-existent server' do

      before do
        error = Errno::ECONNREFUSED
        RestClient.should_receive(:post).with(url, data).and_raise(error)
      end

      it 'should get the key' do
        error_message.should == 'failure connecting: Connection refused'
      end

    end

  end

  describe :upload_path do

    let(:base) { nil }
    let(:error_message) do
      begin
        uploader.upload_path path
        nil # nil otherwise
      rescue Haste::Exception => e
        e.message
      end
    end

    context 'with no path given' do

      let(:path) { nil }

      it 'should have an error' do
        error_message.should == 'No input file given'
      end

    end

    context 'with an invalid path given' do

      let(:path) { '/tmp/why-do-you-have-a-file-called-john' }

      it 'should have an error' do
        error_message.should == "#{path}: No such path"
      end

    end

    context 'with a valid path' do

      let(:data) { 'hello world' }
      let(:path) { '/tmp/real' }
      before { File.open(path, 'w') { |f| f.write(data) } }

      before do
        uploader.should_receive(:upload_raw).with(data) # check
      end

      it 'should not receive an error' do
        error_message.should be_nil
      end

    end

  end

  describe :server_url do

    let(:server_url) { uploader.server_url }

    context 'with default constructor' do

      let(:base) { nil }

      it 'should use the default url' do
        server_url.should == Haste::DEFAULT_URL
      end

    end

    context 'with server url passed in constructor' do

      context 'with a trailing slash' do

        before { @string = 'hello/' }
        let(:base) { @string }

        it 'should remove the slash' do
          server_url.should == @string.chop
        end

        it 'should not modify the original' do
          @string.should == 'hello/'
        end

      end

      context 'with no trailing slash' do

        let(:base) { 'hello' }

        it 'should not chop the url' do
          server_url.should == base
        end

      end

    end

  end

end
