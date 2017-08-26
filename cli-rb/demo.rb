#!/usr/bin/env ruby

require_relative 'cli_utils'

cities = ['Chicago', 'New York', 'Los Angeles', 'San Francisco', 'New Orleans']

filter = CliUtils.create_filter(['New'])

puts "Filter results: #{CliUtils.filter(cities, &filter)}\n\n"

puts "Select result: #{CliUtils.create_options('city', cities, &proc { |city| "#{city}\n" })}\n\n"
