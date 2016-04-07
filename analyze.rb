RACK_ENV ||= ENV["RACK_ENV"] ||= "development" unless defined?(RACK_ENV)

require "rubygems" unless defined?(Gem)
require "bundler/setup"
Bundler.require(:default, RACK_ENV)

File.open('data.json.gz') do |f|
  gz = Zlib::GzipReader.new(f)

  data = JSON.parse(gz.read)
  gz.close
  buckets = {}

  data.each do |r|
    buckets[r["committee"]["name"]] ||= 0
    buckets[r["committee"]["name"]] += (r["contribution_receipt_amount"] * 100).to_i / 100
  end

  buckets.sort {|a, b| a[1] <=> b[1] }.each do |name, amount|
    puts "#{name}: $#{amount}"
  end
end
