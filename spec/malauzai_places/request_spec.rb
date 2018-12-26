require 'spec_helper.rb'

describe MalauzaiPlaces::Request do
	before :each do
		@location = MalauzaiPlaces::Location.new('30.4284750','-97.7550500').format
		@types = ['atm', 'bank']
		@radius = 2000
		@multipage_request = true
		@language = 'en'
	end

	context 'Lists places' do
		it 'should retrieve a list of places' do
			response = MalauzaiPlaces::Request.places(
				:location => @location,
				:radius => @radius,
				:key => api_key
			)
			expect(response['results']).to_not be_empty
		end
	end

end
