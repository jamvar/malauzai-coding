require 'spec_helper'

describe MalauzaiPlaces::Client do
	let(:client) {MalauzaiPlaces::Client.new(api_key, client_options)}
	let(:client_options) {{}}
	
	describe '::api_key' do
		it 'should initialize with an api_key' do
			expect(client.api_key).to eq(api_key)
		end
	end

	describe '::options' do
		it 'should initialize without options' do
			expect(client.options).to eq({})
		end

		context 'with options' do
			let(:client_options) { {radius: 1000, types: ['atm', 'bank'] }}
			it 'should initialize with options' do
				expect(client.options).to eq(client_options)
			end
		end
	end

	describe '::places' do
		let(:lat) {'30.4284750'}
		let(:lng) {'-97.7550500'}
		it 'should request places' do
			expect(MalauzaiPlaces::Place).to receive(:list).with(lat, lng, api_key, {})
			client.places(lat, lng)
		end
	end

	describe 'get places with details', vcr: {cassette_name: 'places_list_with_detail'} do
		let(:lat) {'30.4284750'}
                let(:lng) {'-97.7550500'}
		it 'should return places with information' do
			places = client.places(lat, lng)
			expect(places).to_not be_nil

			places.each do |place|
				expect(place.name).to_not be_nil
				expect(place.types).to_not be_nil
				expect(place.place_id).to_not be_nil
			end
		end
	end
end
