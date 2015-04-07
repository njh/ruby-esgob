$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'esgob'

describe Esgob do

  describe "version number" do
    it "should be defined as a constant" do
      expect(defined?(Esgob::VERSION)).to eq('constant')
    end

    it "should be a string" do
      expect(Esgob::VERSION).to be_a(String)
    end

    it "should be in the format x.y.z" do
      expect(Esgob::VERSION).to match(/^\d{1,2}\.\d{1,2}\.\d{1,2}$/)
    end

  end

end
