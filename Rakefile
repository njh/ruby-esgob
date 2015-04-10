#!/usr/bin/env ruby

$:.push File.expand_path("./lib", __FILE__)

require 'rubygems'
require 'yard'
require 'rake/testtask'
require "bundler/gem_tasks"

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

namespace :doc do
  YARD::Rake::YardocTask.new
end

task :default => :test
