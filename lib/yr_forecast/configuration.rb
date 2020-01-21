module YrForecast
  module Configuration
    BASE_URL = "https://www.yr.no/api/v0"

    def base_url
      @base_url ||= BASE_URL
    end
  end
end
