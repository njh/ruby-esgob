$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'esgob'

describe Esgob::Client do

  before(:each) do
    # Reset environment variables
    ENV.delete('ESGOB_ACCOUNT')
    ENV.delete('ESGOB_API_KEY')
  end

  let(:client) { Esgob::Client.new(:account => 'acct', :api_key => 'api_key') }

  describe "initializing a client" do
    it "with account details from the environment" do
      ENV['ESGOB_ACCOUNT'] = 'envacct'
      ENV['ESGOB_API_KEY'] = 'envkey'
      client = Esgob::Client.new
      expect(client.account).to eq('envacct')
      expect(client.api_key).to eq('envkey')
      expect(client.endpoint).to eq('https://api.esgob.com/1.0/')
    end

    it "with an account and API key as arguments" do
      client = Esgob::Client.new('foobar', 'mykey')
      expect(client.account).to eq('foobar')
      expect(client.api_key).to eq('mykey')
      expect(client.endpoint).to eq('https://api.esgob.com/1.0/')
    end

    it "with an account and API key as a hash" do
      client = Esgob::Client.new(:account => 'hashacct', :api_key => 'hashkey')
      expect(client.account).to eq('hashacct')
      expect(client.api_key).to eq('hashkey')
      expect(client.endpoint).to eq('https://api.esgob.com/1.0/')
    end
  end

end
