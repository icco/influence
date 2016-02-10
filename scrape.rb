RACK_ENV ||= ENV["RACK_ENV"] ||= "development" unless defined?(RACK_ENV)

require "rubygems" unless defined?(Gem)
require "bundler/setup"
Bundler.require(:default, RACK_ENV)

conn = Faraday.new(url: "https://api.open.fec.gov/v1/schedules/schedule_a/?api_key=oXyFx4md0kTkxxq9JNfIRlrOPorXc60dqOVEs4GE&is_individual=true&contributor_employer=Google&min_date=01-01-2015&max_date=12-31-2016&sort=-contribution_receipt_date&per_page=30") do |faraday|
  faraday.request :url_encoded
  faraday.response :logger
  faraday.adapter Faraday.default_adapter
end

response = conn.get do |req|
  req.headers["cache-control"] = "no-cache"
  req.headers['Referer'] = 'https://beta.fec.gov/data/receipts/?is_individual=true&contributor_employer=Google&min_date=01-01-2015&max_date=12-31-2016'
end
data = JSON.parse response.body
p data