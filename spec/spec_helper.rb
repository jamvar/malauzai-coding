require 'rubygems'
require 'bundler/setup'
require 'api_key'
require File.dirname(__FILE__) + '/../' + 'malauzai_places'

def api_key
	RSPEC_API_KEY
end
