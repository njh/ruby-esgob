$:.unshift(File.dirname(__FILE__))

require 'test_helper'
require 'esgob'

class TestConfig < MiniTest::Unit::TestCase
  def teardown
    # Reset environment variables after each test
    ENV.delete('ESGOB_ACCOUNT')
    ENV.delete('ESGOB_KEY')
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

  def test_save_config
    tempfile = Tempfile.new('esgob-config-test')
    tempfile.close

    config = Esgob::Config.new
    config.account = 'a'
    config.key = 'k'
    config.save(tempfile.path)

    assert_equal("account a\nkey k\n", tempfile.open.read)

    tempfile.unlink
  end

end
