require 'rubygems'
require 'erb'
require 'httparty'

module MalauzaiPlaces
    class << self

        attr_accessor :api_key
    
        def configuration
          yield self
        end
    
    end

    class Client
        attr_reader :api_key
        attr_reader :options
    
        def initialize(api_key = @api_key, options = {})
          api_key ? @api_key = api_key : @api_key = MalauzaiPlaces.api_key
          @options = options
        end
    
        def places(lat, lng, options = {})
          options = @options.merge(options)
          detail = options.delete(:detail)
          collection_detail_level(
            Place.list(lat, lng, @api_key, options),
            detail
          )
        end
    
        private
    
        def collection_detail_level(places, detail = false)
          if detail
            places.map do |spot|
              Place.find(spot.place_id, @api_key, @options)
            end
          else
            places
          end
        end
    end

    class APIConnectionError < HTTParty::ResponseError
    end

    class Request
        # This class performs the queries on the API
        # @return [HTTParty::Response] the retrieved response from the API
        attr_accessor :response
        attr_reader :options
    
        include ::HTTParty
        format :json
    
        NEARBY_SEARCH_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
    
        def self.places(options = {})
          request = new(NEARBY_SEARCH_URL, options)
          request.parsed_response
        end
        
        def initialize(url, options)
            @response = self.class.get(url, :query => options)
            # puts @response.request.last_uri.to_s
        end
    
        def execute
          @response = self.class.get(url, :query => options, :follow_redirects => follow_redirects)
        end
    
        def parsed_response
          return @response.headers["location"] if @response.code >= 300 && @response.code < 400
          raise APIConnectionError.new(@response) if @response.code >= 500 && @response.code < 600
          return @response.parsed_response if @response.parsed_response['status'] == 'OK'
        end
    end

    class Location
        def initialize(lat, lng)
          @lat = ("%.8f"%lat)
          @lng = ("%.8f"%lng)
        end
    
        def format
          [ @lat, @lng ].join(',')
        end
    end

    class Place
        attr_accessor :lat, :lng, :name, :reference, :types, :id, :url, :cid, :website, :nextpagetoken, :opening_hours, :place_id, :permanently_closed
        
        def self.list(lat, lng, api_key, options = {})
            location = Location.new(lat, lng)
            multipage_request = !!options.delete(:multipage)
            rankby = options.delete(:rankby)
            radius = options.delete(:radius) || 50000 if rankby.nil?
            types = options.delete(:types)
            name = options.delete(:name)
            language = options.delete(:language)
            exclude = options.delete(:exclude) || []
            exclude = [exclude] unless exclude.is_a?(Array)
            
            options = {
                :location => location.format,
                :radius => radius,
                :rankby => rankby,
                :key => api_key,
                :name => name,
                :language => language
            }
    
          # Accept Types as a string or array
          if types
            types = (types.is_a?(Array) ? types.join('|') : types)
            options.merge!(:types => types)
          end
    
          request(:places, multipage_request, exclude, options)
        end
    
        def self.request(method, multipage_request, exclude, options)
          results = []
    
          self.multi_pages_request(method, multipage_request, options) do |result|
            results << self.new(result, options[:key]) if result['types'].nil? || (result['types'] & exclude) == []
          end
    
          print results
          results
        end
    
        def self.multi_pages_request(method, multipage_request, options)
          begin
            response = Request.send(method, options)
            response['results'].each do |result|
              if !multipage_request && !response["next_page_token"].nil? && result == response['results'].last
                # adding next page token for results more than 20 on the last result
                result.merge!("nextpagetoken" => response["next_page_token"])
              end
              yield(result)
            end

            next_page = false
            if multipage_request && !response["next_page_token"].nil?
              options = {
                :pagetoken => response["next_page_token"],
                :key => options[:key]
              }
    
              # There is a short delay between when a next_page_token is issued, and when it will become valid.
              # If requested too early, it will result in InvalidRequestError.
              # See: https://developers.google.com/places/documentation/search#PlaceSearchPaging
              sleep(2)
    
              next_page = true
            end
    
          end while (next_page)
        end
    
        def initialize(result_object, api_key)
            @lat = result_object['geometry']['location']['lat']
            @lng = result_object['geometry']['location']['lng']
            @name = result_object['name']
            @reference = result_object['reference']
            @types = result_object['types']
            @id = result_object['id']
            @url = result_object['url']
            @cid = result_object['cid']
            @website = result_object['website']
            @opening_hours = result_object['opening_hours']
            @place_id = result_object['place_id']
            @permanently_closed = result_object['permanently_closed']
            @nextpagetoken = result_object['nextpagetoken']
        end
    end
end