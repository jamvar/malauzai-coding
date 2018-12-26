module MalauzaiPlaces
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