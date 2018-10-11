#!/usr/bin/env ruby

require_relative './cc'

ct = CTree.new

ct.define('', 'help') { puts 'help' }
ct.define('', 'add') { |label, usr, pwd| puts "label: #{label}, username: #{usr}, password: #{pwd}" }

ct.exec(['help', 'add'])
