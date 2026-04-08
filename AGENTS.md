# Agent Instructions: yr_forecast

## Quick Commands
- **Setup**: `bin/setup` (bundles dependencies)
- **Test**: `rake test` (default rake task)
- **Console**: `bin/console` (IRB with gem loaded)
- **CLI**: `ruby bin/yr-cli --place "Oslo"` - installed as `yr-cli` when gem is installed
- **Install locally**: `bundle exec rake install`

## Project Overview
Ruby gem wrapper for the [yr.no](https://www.yr.no) weather API.

## Testing Quirks
- Uses **Minitest** with **VCR** for HTTP mocking
- VCR cassettes in `test/vcr_cassettes/` (recorded API responses)
- Tests use `WebMock` for HTTP stubbing
- `rake test` runs all tests; `ruby -Ilib:test test/yr_forecast_test.rb` for single file

## Architecture
- Entry point: `lib/yr_forecast.rb` (module with class methods)
- Configuration: `lib/yr_forecast/configuration.rb` (BASE_URL constant)
- Version: `lib/yr_forecast/version.rb`
- CLI: `bin/yr-cli` - installed as `yr-cli` command when gem is installed

## API Behavior
- `YrForecast.for(place: 'Oslo')` or `YrForecast.for(latitude: x, longitude: y)`
- Calls yr.no REST API at `https://www.yr.no/api/v0`
- Returns hash with weather data + optional watertemperature + pollen data
- Network dependency in production; VCR cassettes for tests

## Dependencies
- Runtime: `resolv-replace` (DNS resolution fix)
- Dev: bundler, rake, minitest, webmock, vcr

## Files to Know
- `yr_forecast.gemspec` - gem spec (includes CLI executable)
- `Rakefile` - test task setup
- `README.md` - usage examples
