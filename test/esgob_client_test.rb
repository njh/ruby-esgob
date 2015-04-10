$:.unshift(File.dirname(__FILE__))

require 'test_helper'
require 'esgob'

class TestClient < MiniTest::Unit::TestCase
  def setup
    # Run before each test
    FakeWeb.clean_registry
    @client = Esgob::Client.new('acct', 'xxxx')
  end

  def teardown
    # Reset environment variables after each test
    ENV.delete('ESGOB_ACCOUNT')
    ENV.delete('ESGOB_API_KEY')
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

  def test_call_with_no_parameters
    register_fixture('accounts.get')
    response = @client.call('accounts.get')
    
    assert_equal(
      '/1.0/accounts.get?account=acct&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
    assert_equal(
      {:credits=>48, :users=>[], :added=>1422792434, :id=>"xyz", :name=>"Person Name"},
      response
    )
  end

  def test_call_with_extra_params
    register_fixture('accounts.get')
    response = @client.call('accounts.get', :foo => :bar)
    
    assert_equal(
      '/1.0/accounts.get?account=acct&f=json&foo=bar&key=xxxx',
      FakeWeb.last_request.path
    )
  end

  def test_call_with_overriding_params
    register_fixture('accounts.get')
    response = @client.call('accounts.get', :account => 'acct2')
    
    assert_equal(
      '/1.0/accounts.get?account=acct2&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
  end

  def test_call_with_404_error
    assert_raises(Net::HTTPServerException) do
      FakeWeb.register_uri(
        :get, %r[https://api.esgob.com/1.0/],
        :status => ["404", "Not Found"],
        :content_type => "application/json",
        :body => '{}'
      )
      response = @client.call('accounts.get')
    end
  end

  def test_call_with_non_json_reponse
    assert_raises(RuntimeError) do
      FakeWeb.register_uri(
        :get, %r[https://api.esgob.com/1.0/],
        :status => ["200", "OK"],
        :content_type => "text/plain",
        :body => 'This is plain text'
      )
      response = @client.call('accounts.get')
    end
  end

end
