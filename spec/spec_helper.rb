# figure out where we are being loaded from
if $LOADED_FEATURES.grep(/spec_helper\.rb/).any?
  begin
    raise "foo"
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require "spec_helper"

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'rose'
require 'spec'
require 'spec/autorun'
require 'reek/spec'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

Spec::Matchers.define :match_table do |expected|
  match do |actual|
    actual.to_s == expected.to_s
  end
  
  failure_message_for_should do |actual|
    "expected:\n#{actual}\nto equal:\n#{expected}"
  end
  
  failure_message_for_should_not do |actual|
    "expected:\n#{actual}\nnot to equal:\n#{expected}"
  end

  description do
    "to match table"
  end
end