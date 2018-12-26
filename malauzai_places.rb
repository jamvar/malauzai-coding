require 'rubygems'
require 'erb'
require 'httparty'

['client', 'error', 'location', 'place', 'request'].each do |file|
    require File.join(File.dirname(__FILE__), 'malauzai_places', file)
end

module MalauzaiPlaces
    class << self

        attr_accessor :api_key
    
    end
end
