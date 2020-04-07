require "test_helper"

class YrForecastTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::YrForecast::VERSION
  end

  def test_get_empty_search
    forecast = YrForecast.for(place: "")
    assert_nil forecast
  end

  def test_get_data_by_search
    forecast = YrForecast.for(place: "Bud")
    assert_equal 13, forecast.count
  end

  def test_get_data_by_coords
    forecast = YrForecast.for(latitude: 59.9128627, longitude: 10.7434443)
    assert_equal 13, forecast.count
  end
end
