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

end
