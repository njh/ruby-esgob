$:.unshift(File.dirname(__FILE__))

require 'test_helper'
require 'esgob'

class TestConfig < MiniTest::Unit::TestCase
  def setup
    # Clear environment variables before each test
    ENV.delete('ESGOB_ACCOUNT')
    ENV.delete('ESGOB_KEY')
  end

  def teardown
    # Reset environment variables after each test
    ENV.delete('ESGOB_ACCOUNT')
    ENV.delete('ESGOB_KEY')
  end

  def test_new
    conf = Esgob::Config.new(:account => 'acct', :key => 'xyz')
    assert_instance_of(Esgob::Config, conf)
    assert_equal('acct', conf.account)
    assert_equal('xyz', conf.key)
  end

  def test_default_values
    conf = Esgob::Config.new
    assert_instance_of(Esgob::Config, conf)
    assert_equal(nil, conf.account)
    assert_equal('https://api.esgob.com/1.0/', conf.endpoint)
    assert_equal(nil, conf.key)
  end

  def test_file_paths
    ENV['HOME'] = '/home/bob'
    assert_instance_of(Array, Esgob::Config.file_paths)
    assert_includes(Esgob::Config.file_paths, '/home/bob/.esgob')
    assert_includes(Esgob::Config.file_paths, '/etc/esgob')
  end

  def test_instance_file_paths
    conf = Esgob::Config.new
    assert_instance_of(Array, conf.file_paths)
    assert_includes(conf.file_paths, '/etc/esgob')
  end

  def test_load_from_env
    ENV['ESGOB_ACCOUNT'] = 'envacct'
    ENV['ESGOB_KEY'] = 'envkey'
    conf = Esgob::Config.load
    assert_instance_of(Esgob::Config, conf)
    assert_equal('envacct', conf.account)
    assert_equal('envkey', conf.key)
  end

  def test_load_from_specific_file
    conf = Esgob::Config.load(fixture_path('config.txt'))
    assert_instance_of(Esgob::Config, conf)
    assert_equal('fileacct', conf.account)
    assert_equal('filekey', conf.key)
  end

  def test_load_from_default_files
    Esgob::Config.expects(:file_paths).with().returns([
      '/doesnt/exist/shuuKee6',
      '/doesnt/exist/ebah4kiH',
      fixture_path('config.txt'),
      '/doesnt/exist/Va5cu9en',
    ])

    conf = Esgob::Config.load
    assert_instance_of(Esgob::Config, conf)
    assert_equal('fileacct', conf.account)
    assert_equal('filekey', conf.key)
  end

  def test_load_unavailable
    Esgob::Config.expects(:file_paths).with().returns([
      '/doesnt/exist/shuuKee6'
    ])

    conf = Esgob::Config.load
    assert_nil(conf)
  end

  def test_each_pair
    conf = Esgob::Config.new(:key => 'xyz', :account => 'abc')
    array = []
    conf.each_pair { |k, v| array << "#{k}=#{v}" }
    assert_equal(["account=abc", "key=xyz"], array)
  end

  def test_save_config
    tempfile = Tempfile.new('esgob-config-test')
    tempfile.close

    config = Esgob::Config.new
    config.account = 'a'
    config.key = 'k'
    config.save(tempfile.path)

    assert_equal(
      "account a\n"+
      "key k\n",
      tempfile.open.read
    )

    tempfile.unlink
  end

  def test_save_config_with_custom_endpoint
    tempfile = Tempfile.new('esgob-config-test')
    tempfile.close

    config = Esgob::Config.new
    config.account = 'a'
    config.key = 'k'
    config.endpoint = 'http://esgob.example.com/'
    config.save(tempfile.path)

    assert_equal(
      "account a\n"+
      "endpoint http://esgob.example.com/\n"+
      "key k\n",
      tempfile.open.read
    )

    tempfile.unlink
  end

end
