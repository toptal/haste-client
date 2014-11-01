require 'spec_helper'

describe Haste::Uploader do

  let(:uploader) { Haste::Uploader.new(base) }

  describe :upload_raw do

    let(:data) { 'hello world' }
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
        ostruct = OpenStruct.new(:status => 200, :body => json)
        expect(uploader.send(:connection)).to receive(:post).with('/documents', data).and_return(ostruct)
      end

      it 'should get the key' do
        expect(error_message).to be_nil # no error
        expect(@key).to eq('hello')
      end

    end

    context 'with a bad json response' do

      let(:json) { '{that:not_even_json}' }

      before do
        ostruct = OpenStruct.new(:status => 200, :body => json)
        expect(uploader.send(:connection)).to receive(:post).with('/documents', data).and_return(ostruct)
      end

      it 'should get an error' do
        expect(error_message).to start_with('failure parsing response: ')
      end

    end

    context 'with a 404 response' do

      before do
        ostruct = OpenStruct.new(:status => 404, :body => 'ohno')
        expect(uploader.send(:connection)).to receive(:post).with('/documents', data).and_return(ostruct)
      end

      it 'should get an error' do
        expect(error_message).to eq('failure uploading: ohno')
      end

    end

    context 'with a non-existent server' do

      before do
        error = Errno::ECONNREFUSED
        expect(uploader.send(:connection)).to receive(:post).with('/documents', data).and_raise(error)
      end

      it 'should get the key' do
        expect(error_message).to eq('failure connecting: Connection refused')
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
        expect(error_message).to eq('No input file given')
      end

    end

    context 'with an invalid path given' do

      let(:path) { '/tmp/why-do-you-have-a-file-called-john' }

      it 'should have an error' do
        expect(error_message).to eq("#{path}: No such path")
      end

    end

    context 'with a valid path' do

      let(:data) { 'hello world' }
      let(:path) { '/tmp/real' }
      before { File.open(path, 'w') { |f| f.write(data) } }

      before do
        expect(uploader).to receive(:upload_raw).with(data) # check
      end

      it 'should not receive an error' do
        expect(error_message).to be_nil
      end

    end

  end

  describe :server_url do

    let(:server_url) { uploader.server_url }

    context 'with default constructor' do

      let(:base) { nil }

      it 'should use the default url' do
        expect(server_url).to eq(Haste::DEFAULT_URL)
      end

    end

    context 'with server url passed in constructor' do

      context 'with a trailing slash' do

        before { @string = 'hello/' }
        let(:base) { @string }

        it 'should remove the slash' do
          expect(server_url).to eq(@string.chop)
        end

        it 'should not modify the original' do
          expect(@string).to eq('hello/')
        end

      end

      context 'with no trailing slash' do

        let(:base) { 'hello' }

        it 'should not chop the url' do
          expect(server_url).to eq(base)
        end

      end

    end

  end

end
