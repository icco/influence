RACK_ENV ||= ENV["RACK_ENV"] ||= "development" unless defined?(RACK_ENV)

require "rubygems" unless defined?(Gem)
require "bundler/setup"
Bundler.require(:default, RACK_ENV)

results = []
conn = Faraday.new(url: "https://api.open.fec.gov/v1/schedules/schedule_a/?api_key=5yyI90SU3Xb73TVlv4wrEhQxYcCwMWCywQiGdYbJ&sort_hide_null=true&is_individual=true&contributor_employer=Google&min_date=01-01-2015&max_date=12-31-2016&sort=-contribution_receipt_date&per_page=30") do |faraday|
  faraday.request :url_encoded
  faraday.response :logger
  faraday.adapter Faraday.default_adapter
end

pagination = {page: 0}
loop do
  response = conn.get do |req|
    if pagination["last_indexes"]
      p pagination
      # {"pages"=>148, "per_page"=>30, "last_indexes"=>{"last_index"=>248209352, "last_contribution_receipt_date"=>"2015-11-20"}, "count"=>4429}
      req.params["last_index"] = pagination["last_indexes"]["last_index"]
      req.params["last_contribution_receipt_date"] = pagination["last_indexes"]["last_contribution_receipt_date"]
    end
    req.headers["cache-control"] = "no-cache"
    req.headers['Referer'] = 'https://beta.fec.gov/data/receipts/?is_individual=true&contributor_employer=Google&min_date=01-01-2015&max_date=12-31-2016'
  end
  data = JSON.parse response.body

  page = pagination[:page] + 1
  pagination = data["pagination"]
  pagination[:page] = page

  data["results"].each do |r|
    results.push r
  end

  File.open("data.json", 'w') { |file| file.write(results.to_json) }
  sleep 5
  if pagination["pages"] < pagination[:page]
    exit
  end
end
