module MalauzaiPlaces
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
        end

        def execute
		@response = self.class.get(url, :query => options, :follow_redirects => follow_redirects)
        end

        def parsed_response
		return @response.headers["location"] if @response.code >= 300 && @response.code < 400
		raise APIConnectionError.new(@response) if @response.code >= 500 && @response.code < 600
		case @response.parsed_response['status']
		when 'OK', 'ZERO_RESULTS'
			@response.parsed_response
		when 'OVER_QUERY_LIMIT'
			raise OverQueryLimitError.new(@response)
		when 'REQUEST_DENIED'
			raise RequestDeniedError.new(@response)
		when 'INVALID_REQUEST'
			raise InvalidRequestError.new(@response)
		when 'UNKNOWN_ERROR'
			raise UnknownError.new(@response)
		when 'NOT_FOUND'
			raise NotFoundError.new(@response)
		end
        end
    end
end
