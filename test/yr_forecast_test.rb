require "test_helper"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
end

class YrForecastTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::YrForecast::VERSION
  end

  def test_get_empty_search
    VCR.use_cassette("test_get_empty_search") do
      forecast = YrForecast.for(place: "")
      assert_nil forecast
    end
  end

  def test_get_data_by_search
    VCR.use_cassette("test_get_data_by_search") do
      forecast = YrForecast.for(place: "Bud")
      assert_equal 15, forecast.count
    end
  end

  def test_get_data_by_coords
    VCR.use_cassette("test_get_data_by_coords") do
      forecast = YrForecast.for(latitude: 59.9128627, longitude: 10.7434443)
      assert_equal 15, forecast.count
    end
  end

  def test_get_data_by_other_coords
    VCR.use_cassette("test_get_data_by_other_coords") do
      forecast = YrForecast.for(latitude: 69.648405, longitude: 18.959708)
      assert_equal 15, forecast.count
    end
  end
end
