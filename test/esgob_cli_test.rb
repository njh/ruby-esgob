$:.unshift(File.dirname(__FILE__))

require 'test_helper'
require 'esgob'

class TestCLI < MiniTest::Unit::TestCase
  def setup
    # Run before each test
    FakeWeb.clean_registry

    @client = Esgob::Client.new('acct', 'xxxx')
    Esgob::Client.stubs(:new).returns(@client)

    #ENV["THOR_SHELL"] = 'Basic'
  end

  def teardown
    # Reset environment variables after each test
    ENV.delete('ESGOB_ACCOUNT')
    ENV.delete('ESGOB_API_KEY')
  end
  
  def test_account
    register_fixture('accounts.get')

    output = capture(:stdout) { Esgob::CLI.start(%w[account]) }
    assert_match "      id: xyz\n", output
    assert_match "    name: Person Name\n", output
    assert_match " credits: 48\n", output
  end
  
  def test_domains
    register_fixture('domains.list')

    output = capture(:stdout) { Esgob::CLI.start(%w[domains]) }
    assert_match "Domain       Type\n", output
    assert_match "------       ----\n", output
    assert_match "example.com  slave\n", output
    assert_match "example.uk   slave\n", output
  end
  
  def test_slaves
    register_fixture('domains.slaves.list')

    output = capture(:stdout) { Esgob::CLI.start(%w[slaves]) }
    assert_match "Domain       Master IP\n", output
    assert_match "------       ---------\n", output
    assert_match "example.com  195.177.253.166\n", output
    assert_match "example.uk   195.177.253.166\n", output
  end

  def test_slaves_add
    register_fixture('domains.slaves.add')

    output = capture(:stdout) { Esgob::CLI.start(%w[slaves-add example.org 195.177.253.166]) }
    assert_match "=> domain added\n", output
  end
  
  def test_slaves_delete
    register_fixture('domains.slaves.delete')

    output = capture(:stdout) { Esgob::CLI.start(%w[slaves-delete example.org]) }
    assert_match "=> domain deleted\n", output
  end
  
  def test_slaves_transfer
    register_fixture('domains.slaves.forcetransfer')

    output = capture(:stdout) { Esgob::CLI.start(%w[slaves-transfer example.org]) }
    assert_match "=> Domain AXFR requested from master\n", output
  end
  
  def test_slaves_update
    register_fixture('domains.slaves.updatemasterip')

    output = capture(:stdout) { Esgob::CLI.start(%w[slaves-update example.org 195.177.253.167]) }
    assert_match "=> domain master IP updated\n", output
  end
  
  def test_version
    assert_match /Esgob Ruby Client version \d+.\d+\.\d+/,
      capture(:stdout) { Esgob::CLI.start(%w[version]) }
  end
end
