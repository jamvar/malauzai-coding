require 'spec_helper'

describe MalauzaiPlaces::Place do
	before :each do
		@lat = '30.4284750'
		@lng = '-97.7550500'
		@radius = 2000
		@language = 'es'
		@types = ['atm', 'bank']
	end

	context 'list places by options' do
		after :each do
			@collection = MalauzaiPlaces::Place.list(@lat, @lng, api_key, :language => @language, :types => ['atm', 'bank'])
		end

		it 'should send types and language options' do
			expect(MalauzaiPlaces::Place).to receive(:multi_pages_request).with(
				:places,
				false,
				{
					location: '30.42847500,-97.75505000',
					rankby: 'distance',
					key: RSPEC_API_KEY,
					radius: nil,
					name: nil,
					language: 'es',
					types: 'atm|bank'
				})
		end
	end

	context 'list places', vcr: {cassette_name: 'list_places'} do
		after(:each) do
			expect(@collection.map(&:class).uniq).to eq [MalauzaiPlaces::Place]
		end

		it 'is a collection of places' do
			@collection = MalauzaiPlaces::Place.list(@lat, @lng, api_key, :radius => @radius)
		end

		describe 'with a single type', vcr: {cassette_name: 'list_places_one_type'} do
			before(:each) do
				@collection = MalauzaiPlaces::Place.list(@lat, @lng, api_key, :radius => @radius, :types => 'atm')
			end

			it 'should have places with specific type' do
				@collection.each do |place|
					expect(place.types).to include('atm')
				end
			end
		end

		describe 'with multiple types', vcr: {cassette_name: 'list_places_multiple_types'} do
			before :each do
				@collection = MalauzaiPlaces::Place.list(@lat, @lng, api_key, :radius => @radius, :types => ['atm','bank'])
			end

			it 'should have plaes with mentioned types' do
				@collection.each do |place|
					expect(place.types & ['atm','bank']).to be_any
				end
			end
		end

		describe 'with language and types', vcr: {cassette_name: 'list_places_with_language_and_types'} do
			before :each do
				@collection = MalauzaiPlaces::Place.list(@lat, @lng, api_key, :radius => @radius, :types => ['atm','bank'], :language => 'es')
			end

			it 'should have language and mentioned types' do
				@collection.each do |place|
					expect(place.types & ['atm','bank']).to be_any
					expect(place.language)
				end
			end
		end
	end

	context 'Multiple page request scenarios', vcr: {cassette_name: 'multipage_request_list'} do
		it 'should return more than 20 results when :multipage_request is true' do
			@collection = MalauzaiPlaces::Place.list(@lat, @lng, api_key, :radius => @radius, :types => 'atm', :language => 'es', :multipage => true)
			expect(@collection.size).to be >= 21
		end

		it 'should return max 20 results when :multipage is false' do
			@collection = MalauzaiPlaces::Place.list(@lat, @lng, api_key, :radius => @radius, :types => 'atm', :language => 'es', :multipage => false)
			expect(@collection.size).to be <= 20
		end

		it 'should return max 20 results when :multipage is not present' do
			@collection = MalauzaiPlaces::Place.list(@lat, @lng, api_key, :radius => @radius, :types => 'atm', :language => 'es')
			expect(@collection.size).to be <= 20
		end

		it 'should return a pagetoken when there is more than 20 results and :multipage is false' do
			@collection = MalauzaiPlaces::Place.list(@lat, @lng, api_key, :radius => @radius, :types => 'atm', :language => 'es', :multipage => false)
			expect(@collection.last.nextpagetoken).to_not be_nil
		end
	end
end

