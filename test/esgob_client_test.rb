$:.unshift(File.dirname(__FILE__))

require 'test_helper'
require 'esgob'

class TestClient < MiniTest::Unit::TestCase
  def setup
    # Clear environment variables before each test
    ENV.delete('ESGOB_ACCOUNT')
    ENV.delete('ESGOB_KEY')
    FakeWeb.clean_registry
    @client = Esgob::Client.new('acct', 'xxxx')
  end

  def teardown
    # Reset environment variables after each test
    ENV.delete('ESGOB_ACCOUNT')
    ENV.delete('ESGOB_KEY')
  end

  def test_new_client_using_environment
    ENV['ESGOB_ACCOUNT'] = 'envacct'
    ENV['ESGOB_KEY'] = 'envkey'

    client = Esgob::Client.new
    assert_equal 'envacct', client.config.account
    assert_equal 'envkey', client.config.key
    assert_equal 'https://api.esgob.com/1.0/', client.config.endpoint
  end

  def test_new_client_using_arguments
    client = Esgob::Client.new('foobar', 'mykey')
    assert_equal 'foobar', client.config.account
    assert_equal 'mykey', client.config.key
    assert_equal 'https://api.esgob.com/1.0/', client.config.endpoint
  end

  def test_new_client_using_hash
    client = Esgob::Client.new(
      :account => 'hashacct',
      :key => 'hashkey',
      :endpoint => 'http://api.example.com/'
    )
    assert_equal 'hashacct', client.config.account
    assert_equal 'hashkey', client.config.key
    assert_equal 'http://api.example.com/', client.config.endpoint
  end

  def test_new_client_using_config
    config = Esgob::Config.new(
      :account => 'confacct',
      :key => 'confkey'
    )
    client = Esgob::Client.new(config)
    assert_equal 'confacct', client.config.account
    assert_equal 'confkey', client.config.key
  end

  def test_new_client_with_no_config_files
    Esgob::Config.expects(:default_filepaths).with().returns([])
    err = assert_raises(RuntimeError) { Esgob::Client.new }
    assert_equal 'Unable to load Esgob configuration', err.message
  end

  def test_new_client_with_no_account
    ENV.delete('ESGOB_ACCOUNT')
    err = assert_raises(ArgumentError) do
      Esgob::Client.new(nil, 'mykey')
    end
    assert_equal 'No account name configured for Esgob', err.message
  end

  def test_new_client_with_no_key
    ENV.delete('ESGOB_KEY')
    err = assert_raises(ArgumentError) do
      Esgob::Client.new('acct', nil)
    end
    assert_equal 'No API key configured for Esgob', err.message
  end

  def test_new_client_unsupported_arguments
    err = assert_raises(ArgumentError) do
      Esgob::Client.new(1, 2, 3, 4)
    end
    assert_equal 'Unsupported arguments for creating Esgob::Client', err.message
  end

  def test_call_with_no_parameters
    register_fixture('accounts.get')
    response = @client.call('accounts.get')

    assert_equal(
      '/1.0/accounts.get?account=acct&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
    assert_equal(
      {
        :credits => 48,
        :users => [],
        :added => 1422792434,
        :id => 'xyz',
        :name => 'Person Name'
      },
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
    FakeWeb.register_uri(
      :get, %r{^https?://api\.esgob\.com(:443)?/},
      :status => ['404', 'Not Found'],
      :content_type => 'application/json',
      :body => '{}'
    )
    err = assert_raises(Esgob::ServerError) { @client.call('accounts.get') }
    assert_equal 'Not Found', err.message
    assert_equal '404', err.code
  end

  def test_call_with_non_json_reponse
    FakeWeb.register_uri(
      :get, %r{^https?://api\.esgob\.com(:443)?/},
      :status => ['200', 'OK'],
      :content_type => 'text/plain',
      :body => 'This is plain text'
    )
    err = assert_raises(RuntimeError) { @client.call('accounts.get') }
    assert_equal 'HTTP response from ESGOB is not of type JSON', err.message
  end

  def test_call_domain_not_present
    FakeWeb.register_uri(
      :get, %r{^https?://api\.esgob\.com(:443)?/},
      :status => ['403', 'FORBIDDEN'],
      :content_type => 'application/json',
      :body => read_fixture(:code_2007)
    )
    err = assert_raises(Esgob::ServerError) { @client.call('domains.slaves.delete', :domain => 'example.org') }
    assert_equal 'Domain is not present in your account', err.message
    assert_equal '2007', err.code
  end

  def test_accounts_get
    register_fixture('accounts.get')
    response = @client.accounts_get

    assert_equal(
      '/1.0/accounts.get?account=acct&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
    assert_equal(
      {
        :credits => 48,
        :users => [],
        :added => Time.parse('2015-02-01 12:07:14 +0000'),
        :id => 'xyz',
        :name => 'Person Name'
      },
      response
    )
  end

  def test_domains_list
    register_fixture('domains.list')
    response = @client.domains_list

    assert_equal(
      '/1.0/domains.list?account=acct&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
    assert_equal(
      [
        { :domain => 'example.com', :type => 'slave' },
        { :domain => 'example.uk',  :type => 'slave' }
      ],
      response
    )
  end

  def test_domains_slaves_list
    register_fixture('domains.slaves.list')
    response = @client.domains_slaves_list

    assert_equal(
      '/1.0/domains.slaves.list?account=acct&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
    assert_equal(
      { 'example.com' => '195.177.253.166', 'example.uk' => '195.177.253.166' },
      response
    )
  end

  def test_domains_slaves_add
    register_fixture('domains.slaves.add')
    response = @client.domains_slaves_add('example.org', '195.177.253.166')

    assert_equal(
      '/1.0/domains.slaves.add?account=acct&domain=example.org&f=json&key=xxxx&masterip=195.177.253.166',
      FakeWeb.last_request.path
    )
    assert_equal({ :action => 'domain added', :domain => 'example.org' }, response)
  end

  def test_domains_slaves_delete
    register_fixture('domains.slaves.delete')
    response = @client.domains_slaves_delete('example.org')

    assert_equal(
      '/1.0/domains.slaves.delete?account=acct&domain=example.org&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
    assert_equal({ :action => 'domain deleted', :domain => 'example.org' }, response)
  end

  def test_domains_slaves_forcetransfer
    register_fixture('domains.slaves.forcetransfer')
    response = @client.domains_slaves_forcetransfer('example.org')

    assert_equal(
      '/1.0/domains.slaves.forcetransfer?account=acct&domain=example.org&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
    assert_equal({ :action => 'Domain AXFR requested from master', :domain => 'example.org' }, response)
  end

  def test_domains_slaves_updatemasterip
    register_fixture('domains.slaves.updatemasterip')
    response = @client.domains_slaves_updatemasterip('example.org', '195.177.253.167')

    assert_equal(
      '/1.0/domains.slaves.updatemasterip?account=acct&domain=example.org&f=json&key=xxxx&masterip=195.177.253.167',
      FakeWeb.last_request.path
    )
    assert_equal({ :action => 'domain master IP updated', :domain => 'example.org' }, response)
  end

  def test_domains_slaves_axfrout_add
    register_fixture('domains.slaves.axfrout.add')
    response = @client.domains_slaves_axfrout_add('example.org', '195.177.253.1')

    assert_equal(
      '/1.0/domains.slaves.axfrout.add?account=acct&axfrip=195.177.253.1&domain=example.org&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
    assert_equal({ :action => 'domain AXFR out IPs updated', :domain => 'example.org' }, response)
  end

  def test_domains_slaves_axfrout_delete
    register_fixture('domains.slaves.axfrout.delete')
    response = @client.domains_slaves_axfrout_delete('example.org', '195.177.253.1')

    assert_equal(
      '/1.0/domains.slaves.axfrout.delete?account=acct&axfrip=195.177.253.1&domain=example.org&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
    assert_equal({ :action => 'domain AXFR out IPs updated', :domain => 'example.org' }, response)
  end

  def test_domains_tools_soacheck
    register_fixture('domains.tools.soacheck')
    response = @client.domains_tools_soacheck('example.org')

    assert_equal(
      '/1.0/domains.tools.soacheck?account=acct&domain=example.org&f=json&key=xxxx',
      FakeWeb.last_request.path
    )
    assert_equal('example.org', response[:domain])
    refute_empty(response[:responses])
  end

  def test_domains_slaves_sync_noop
    @client.expects(:domains_slaves_list).with().returns(
      'a.com' => '195.177.253.1', 'b.com' => '195.177.253.1'
    )

    responses = @client.domains_slaves_sync(['a.com', 'b.com'], '195.177.253.1')
    assert_equal [], responses
  end

  def test_domains_slaves_sync_add_only
    @client.expects(:domains_slaves_list).with().returns({})
    @client.expects(:domains_slaves_add).with('a.com', '195.177.253.1').returns(:action => 'domain added')
    @client.expects(:domains_slaves_add).with('b.com', '195.177.253.1').returns(:action => 'domain added')

    responses = @client.domains_slaves_sync(['a.com', 'b.com'], '195.177.253.1')
    assert_equal [
      { :action => 'domain added', :domain => 'a.com' },
      { :action => 'domain added', :domain => 'b.com' }
    ], responses
  end

  def test_domains_slaves_sync_add_and_delete
    @client.expects(:domains_slaves_list).with().returns({'a.com' => '195.177.253.1'})
    @client.expects(:domains_slaves_delete).with('a.com').returns({:action => 'domain deleted'})
    @client.expects(:domains_slaves_add).with('b.com', '195.177.253.1').returns(:action => 'domain added')

    responses = @client.domains_slaves_sync(['b.com'], '195.177.253.1')
    assert_equal [
      { :action => 'domain added', :domain => 'b.com' },
      { :action => 'domain deleted', :domain => 'a.com' }
    ], responses
  end

  def test_domains_slaves_sync_add_and_delete_and_change_masterip
    @client.expects(:domains_slaves_list).with().returns(
      'a.com' => '195.177.253.1', 'c.com' => '127.0.0.1'
    )
    @client.expects(:domains_slaves_delete).with('a.com').returns(:action => 'domain deleted')
    @client.expects(:domains_slaves_add).with('b.com', '195.177.253.1').returns(:action => 'domain added')
    @client.expects(:domains_slaves_updatemasterip).with('c.com', '195.177.253.1').returns(:action => 'domain master IP updated')

    responses = @client.domains_slaves_sync(['b.com', 'c.com'], '195.177.253.1')
    assert_equal [
      { :action => 'domain added', :domain => 'b.com' },
      { :action => 'domain deleted', :domain => 'a.com' },
      { :action => 'domain master IP updated', :domain => 'c.com' }
    ], responses
  end

  def test_inspect
    assert_match('#<Esgob::Client account=acct>', @client.inspect)
  end
end
