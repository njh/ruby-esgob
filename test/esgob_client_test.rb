$:.unshift(File.dirname(__FILE__))

require 'test_helper'
require 'esgob'

class TestClient < MiniTest::Unit::TestCase
  def setup
    @client = Esgob::Client.new('acct', 'xxxx')
  end

  def test_new_client_using_environment
    ENV['ESGOB_ACCOUNT'] = 'envacct'
    ENV['ESGOB_API_KEY'] = 'envkey'
    
    client = Esgob::Client.new
    assert_equal 'envacct', client.account
    assert_equal 'envkey', client.api_key
    assert_equal 'https://api.esgob.com/1.0/', client.endpoint
  end

  def test_new_client_using_arguments
    client = Esgob::Client.new('foobar', 'mykey')
    assert_equal 'foobar', client.account
    assert_equal 'mykey', client.api_key
    assert_equal 'https://api.esgob.com/1.0/', client.endpoint
  end

  def test_new_client_using_hash
    client = Esgob::Client.new(
      :account => 'hashacct',
      :api_key => 'hashkey',
      :endpoint => 'http://api.example.com/'
    )
    assert_equal 'hashacct', client.account
    assert_equal 'hashkey', client.api_key
    assert_equal 'http://api.example.com/', client.endpoint
  end

end
