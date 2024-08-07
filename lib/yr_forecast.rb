require "yr_forecast/configuration"
require "yr_forecast/version"
require "net/http"
require "json"
require "time"
require "resolv-replace"

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
      response["watertemperature"] = watertemperature_for(location, options)
      response["pollen"] = pollen_for(location, options)
      response
    end

    def watertemperature_for(location, options)
      options = { order_by: "dist" }.merge(options)

      res = get_watertemperatures(location)
      return unless res.is_a?(Net::HTTPSuccess)

      parsed_response = JSON.parse(res.body)
      datas = parsed_response["_embedded"]["nearestLocations"]

      return [] if datas.count == 0

      if options[:order_by].eql?("time")
        datas.each {|data| data["sorttime"] = Time.parse(data["time"]).to_datetime }
        datas.sort! {|a, b| b["sorttime"] <=> a["sorttime"] }
        datas[0].delete("sorttime")
      else
        datas.sort! {|a, b| a["distanceFromLocation"] <=> b["distanceFromLocation"] }
      end
      watertemperature = datas[0]
      watertemperature
    end

    def pollen_for(location, options)
      res = get_pollen(location)

      return unless res.is_a?(Net::HTTPSuccess)

      parsed_response = JSON.parse(res.body)
      datas = parsed_response["_embedded"]["pollenForecast"]

      return [] if datas.count == 0

      datas[0]["distributions"].map do |key, val|
        val["pollenTypes"].map do |type|
          {
            type: type["id"],
            name: type["name"],
            amount: key
          }
        end
      end.flatten
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

      def get_pollen(location)
        call_api(location, "pollen")
      end

      def call_api(location, resource)
        id = location["id"]
        uri = URI(YrForecast.base_url + "/locations/#{id}/#{resource}")
        Net::HTTP.get_response(uri)
      end
  end
end