require "yr_forecast/configuration"
require "yr_forecast/version"
require "net/http"
require "json"
require "time"

module YrForecast
  extend Configuration

  class << self
    def for(options)
      location = location_for(options)
      return unless location

      res = get_forecast(location)
      return unless res.is_a?(Net::HTTPSuccess)

      parsed_response = JSON.parse(res.body)
      intervals = parsed_response["shortIntervals"]

      response = intervals[0]
      response["location"] = location
      response["watertemperature"] = watertemperature_for(location)
      response
    end

    def watertemperature_for(location)
      res = get_watertemperatures(location)
      return unless res.is_a?(Net::HTTPSuccess)

      parsed_response = JSON.parse(res.body)
      datas = parsed_response["_embedded"]["nearestLocations"]

      return [] if datas.count == 0

      datas.each {|data| data["sorttime"] = Time.parse(data["time"]).to_datetime }
      datas.sort! {|a, b| b["sorttime"] <=> a["sorttime"] }
      watertemperature = datas[0]
      watertemperature.delete("sorttime")
      watertemperature
    end

    private
      def location_for(options)
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

        unless place.nil? || place.empty?
          params = { q: place }
        else
          params = { lat: latitude, lon: longitude, accuracy: 1000, language: "en" }
        end

        uri = URI(YrForecast.base_url + "/locations/search")
        uri.query = URI.encode_www_form(params)
        Net::HTTP.get_response(uri)
      end

      def get_forecast(location)
        call_api(location, "forecast")
      end

      def get_watertemperatures(location)
        call_api(location, "nearestwatertemperatures")
      end

      def call_api(location, resource)
        id = location["id"]
        uri = URI(YrForecast.base_url + "/locations/#{id}/#{resource}")
        Net::HTTP.get_response(uri)
      end
  end
end
