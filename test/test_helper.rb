$:.unshift(File.join(File.dirname(__FILE__),'..','lib'))

require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)
require 'minitest/autorun'
require 'mocha/mini_test'

unless RUBY_VERSION =~ /^1\.8/
  SimpleCov.start
end

FakeWeb.allow_net_connect = false


def read_fixture(fixture_name)
  fixture_file = File.join(File.dirname(__FILE__), 'fixtures', "#{fixture_name}.json")
  File.read(fixture_file)
end

def register_fixture(api_call, fixture_name=nil)
  if fixture_name.nil?
    fixture_name = api_call.gsub(/\W+/, '_')
  end

  FakeWeb.register_uri(
    :get, %r[^https?://api\.esgob\.com(:443)?/1.0/#{api_call}],
    :status => ["200", "OK"],
    :content_type => "application/json",
    :body => read_fixture(fixture_name)
  )
end

def capture(stream)
  original = eval "$#{stream}"
  eval "$#{stream} = StringIO.new"
  yield
  result = eval("$#{stream}").string
  eval "$#{stream} = original"
  result
end
