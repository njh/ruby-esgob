$:.unshift(File.join(File.dirname(__FILE__),'..','lib'))

require 'rubygems'
require 'bundler'
require 'minitest/autorun'

Bundler.require(:default, :development)

unless RUBY_VERSION =~ /^1\.8/
  SimpleCov.start
end

FakeWeb.allow_net_connect = false


def register_fixture(api_call, fixture_name=nil)
  if fixture_name.nil?
    fixture_name = api_call.gsub(/\W+/, '_')
  end

  fixture_file = File.join(File.dirname(__FILE__), 'fixtures', fixture_name + '.json')
  
  FakeWeb.register_uri(
    :get, %r[https://api.esgob.com/1.0/#{api_call}],
    :status => ["200", "OK"],
    :content_type => "application/json",
    :body => File.read(fixture_file)
  )
end
