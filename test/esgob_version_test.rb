$:.unshift(File.dirname(__FILE__))

require 'test_helper'
require 'esgob'

class TestVersion < MiniTest::Unit::TestCase
  def test_version_number_looks_sensible
    assert_equal 'constant', defined?(Esgob::VERSION)
    assert_kind_of String, Esgob::VERSION
    assert_match /^\d{1,2}\.\d{1,2}\.\d{1,2}$/, Esgob::VERSION
  end
end
