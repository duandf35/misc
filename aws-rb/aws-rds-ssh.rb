#!/usr/bin/env ruby

require_relative '../cli-rb/color'
require_relative '../cli-rb/cli_utils'
require_relative '../cli-rb/cli_validator'
require_relative 'aws-env-msg'

module Rds
  class Cli
    include Color, CliUtils, CliValidator

    def initialize
      @db_name = 'test'
      @usr = 'user'
      @pwd = 'password'
      @dump = ARGV.include?('--dump')
      @dump_path = "#{ENV['HOME']}/.tmp"
      @target_instances = []
      @refresh_cache = false
      @cache_path = "#{ENV['HOME']}/.tmp"
      @cache_prefix = 'rds'
    end

    def parse_args
      help_info = ['-u <user>  | set user',
                   '-p <pwd>   | set password',
                   '-d <db>    | set database',
                   '-f <regex> | rds instance regex',
                   '--refresh  | refresh cached instance list',
                   '--dump     | dump database'].join("\n")

      while ARGV.any?
        case ARGV.shift
          when '-u'
            @usr = next?(ARGV, 'usage: -u username')
          when '-p'
            @pwd = next?(ARGV, 'usage: -p password')
          when '-d'
            @db_name = next?(ARGV, 'usage: -d database')
          when '-f' || '--filter'
            while ARGV.first =~ /^\w/ do @target_instances << ARGV.shift end
          when '--dump'
            @dump = true
          when '--refresh'
            @refresh_cache = true
          else
            raise help_info
        end
      end
    end

    def main
      parse_args

      @env_mg = EnvManager.new.select_acct

      desc = proc do |instance|
        status = instance[:db_instance_status]
        cs = g(status)
        cs = r(status) if status != 'available'

        endpoint = "#{instance[:endpoint_address]}:#{instance[:endpoint_port]}"

        "status: #{cs}, #{y(instance[:db_name])}, endpoint: #{y(endpoint)}\n"
      end

      instance_list = fetch_instance_list(@env_mg.profile)
      instance_list = filter(instance_list, &create_filter(@target_instances, :db_name)).sort! { |a, b| a[:db_name] <=> b[:db_name] }

      db = create_options('rds instance', instance_list, &desc)

      if @dump
        dump(db)
      else
        ssh(db)
      end
    end

    def fetch_instance_list(profile)
      instance_list = read_cache(@cache_path, @cache_prefix, profile) { |props| { db_name: props[0], db_instance_status: props[1], endpoint_address: props[2], endpoint_port: props[3] } }
      instance_list = [] if @refresh_cache
      return instance_list if instance_list.any?

      @rds = Aws::RDS::Client.new(profile: profile)
      @rds.describe_db_instances[:db_instances].each do |instance|
        instance_detail = { db_name: instance[:db_instance_arn].split(':').last,
                            db_instance_status: instance[:db_instance_status] }

        endpoint = instance[:endpoint] || {}

        instance_detail[:endpoint_address] = endpoint[:address] || 'N/A'
        instance_detail[:endpoint_port] = endpoint[:port] || ''
        instance_list << instance_detail
      end

      write_cache(instance_list, @cache_path, @cache_prefix, profile)
      instance_list
    end

    def dump(instance)
      exec("PGPASSWORD=#{@pwd} pg_dump --host=#{instance[:endpoint_address]} --port=#{instance[:endpoint_port]} --dbname=#{@db_name} --username=#{@usr} > #{@dump_path}/#{instance[:db_name]}-dump")
    end

    def ssh(instance)
      cmd = "PGPASSWORD=#{@pwd} psql --host=#{instance[:endpoint_address]} --port=#{instance[:endpoint_port]} --dbname=#{@db_name} --username=#{@usr}"
      append_to_bash_history(cmd)
      exec(cmd)
    end
  end
end

begin
  Rds::Cli.new.main
rescue RuntimeError => e
  puts(e.message)
  exit(1)
end
