require 'rubygems'
require 'erb'
require 'httparty'
# require 'json'
# require 'active_support/core_ext/hash'

['client', 'error', 'location', 'place', 'request'].each do |file|
    require File.join(File.dirname(__FILE__), 'malauzai_places', file)
end

module MalauzaiPlaces
    class << self

        attr_accessor :api_key

	def configuration
		yield self
	end
    
    end
end
