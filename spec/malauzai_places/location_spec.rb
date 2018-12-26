require 'spec_helper'

describe MalauzaiPlaces::Location do
	it 'should return a location with latitude and longitude' do
		expect(MalauzaiPlaces::Location.new('30.4284750','-97.7550500').format).to eq('30.42847500,-97.75505000')
	end
end
