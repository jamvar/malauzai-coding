require 'spec_helper'

describe MalauzaiPlaces do
	it "should be not able to initialize without any params" do
		client = MalauzaiPlaces::Client.new
		expect(client.api_key).to be(nil)
	end

	shared_examples "config api_key" do
		it "should be able to config api_key" do
			MalauzaiPlaces.configuration do |config|
				config.api_key = 'abc'
			end
			client = MalauzaiPlaces::Client.new
			expect(client.api_key).to eq('abc')
		end
	end

	include_examples "config api_key" do
		it "should be able to config api_key and overide it" do
			client = MalauzaiPlaces::Client.new('abc')
			expect(client.api_key).not_to eq('123')
			client = MalauzaiPlaces::Client.new('123')
			expect(client.api_key).to eq('123')
		end
	end
end
