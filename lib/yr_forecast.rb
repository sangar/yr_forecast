require "yr_forecast/configuration"
require "yr_forecast/version"
require "net/http"
require "json"

module YrForecast
  extend Configuration

  class << self
    def for(options)
      location = location(options)
      return unless location

      res = get_forecast(location)
      return unless res.is_a?(Net::HTTPSuccess)

      parsed_response = JSON.parse(res.body)
      intervals = parsed_response["shortIntervals"]
      forecast = intervals[0]
      forecast["location"] = location
      forecast
    end

    private
      def location(options)
        options = { place: "", latitude: nil, longitude: nil }.merge(options)

        res = get_location(options)
        return unless res.is_a?(Net::HTTPSuccess)

        parsed_response = JSON.parse(res.body)
        embedded = parsed_response["_embedded"]
        return unless embedded

        location = embedded["location"][0]
        location.delete("_links")
        location
      end

      def get_location(options)
        place = options[:place]
        latitude = options[:latitude]
        longitude = options[:longitude]

        uri = URI(YrForecast.base_url + "/locations/search")
        unless place.nil? || place.empty?
          params = { q: place }
        else
          params = { lat: latitude, lon: longitude, accuracy: 1000, language: "en" }
        end
        uri.query = URI.encode_www_form(params)

        Net::HTTP.get_response(uri)
      end

      def get_forecast(location)
        id = location["id"]
        uri = URI(YrForecast.base_url + "/locations/#{id}/forecast")
        Net::HTTP.get_response(uri)
      end
  end
end
