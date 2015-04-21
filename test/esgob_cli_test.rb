$:.unshift(File.dirname(__FILE__))

require 'test_helper'
require 'esgob'

class TestCLI < MiniTest::Unit::TestCase
  def setup
    # Run before each test
    FakeWeb.clean_registry

    @client = Esgob::Client.new('acct', 'xxxx')
    Esgob::Client.stubs(:new).returns(@client)

    ENV["THOR_SHELL"] = 'Basic'
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
    assert_equal "example.org => domain added\n", output
  end

  def test_slaves_delete
    register_fixture('domains.slaves.delete')

    output = capture(:stdout) { Esgob::CLI.start(%w[slaves-delete example.org]) }
    assert_equal "example.org => domain deleted\n", output
  end

  def test_slaves_delete_error
    FakeWeb.register_uri(
      :get, %r[^https?://api\.esgob\.com(:443)?/],
      :status => ["403", "FORBIDDEN"],
      :content_type => "application/json",
      :body => read_fixture(:code_2007)
    )

    output = capture(:stderr) { Esgob::CLI.start(%w[slaves-delete example.com]) }
    assert_equal "=> Error: Domain is not present in your account [2007]\n", output
  end

  def test_slaves_transfer
    register_fixture('domains.slaves.forcetransfer')

    output = capture(:stdout) { Esgob::CLI.start(%w[slaves-transfer example.org]) }
    assert_equal "example.org => Domain AXFR requested from master\n", output
  end

  def test_slaves_update
    register_fixture('domains.slaves.updatemasterip')

    output = capture(:stdout) { Esgob::CLI.start(%w[slaves-update example.org 195.177.253.167]) }
    assert_equal "example.org => domain master IP updated\n", output
  end

  def test_slaves_sync
    @client.expects(:domains_slaves_list).with().returns({'a.com' => '195.177.253.169', 'b.com' => '195.177.253.169'})
    @client.expects(:domains_slaves_delete).with('a.com').returns({:action => "domain deleted"})
    @client.expects(:domains_slaves_add).with('c.com', '195.177.253.169').returns({:action => "domain added"})

    output = capture(:stdout) { Esgob::CLI.start(['slaves-sync', fixture_path('sync-domain-list.txt'), '195.177.253.169']) }
    assert_match "a.com => domain deleted\n", output
    assert_match "c.com => domain added\n", output
  end

  def test_soacheck
    register_fixture('domains.tools.soacheck')

    output = capture(:stdout) { Esgob::CLI.start(%w[soacheck example.org]) }
    assert_match "Identifier       Type     Country  SOA  Response\n", output
    assert_match "----------       ----     -------  ---  --------\n", output
    assert_match "195.177.253.167  master                 fail\n", output
    assert_match "4f31ad80         anycast  gb            fail\n", output
    assert_match "fgej72a1         anycast  us            fail\n", output
  end

  def test_version
    assert_match /Esgob Ruby Client version \d+.\d+\.\d+/,
      capture(:stdout) { Esgob::CLI.start(%w[version]) }
  end
end
