ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'minitest/reporters' # requires the gem
require 'rack/test'
require File.expand_path '../../lib/zimbra_preauth_service.rb', __FILE__

# spec-like progress
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
