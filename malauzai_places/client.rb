module MalauzaiPlaces
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
            places.map do |place|
              Place.find(place.place_id, @api_key, @options)
            end
          else
            places
          end
        end
    end
end
