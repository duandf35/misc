require 'yaml'
require_relative '../cli-rb/cli_utils'
require_relative '../cli-rb/color'

class EnvManager
  include Color, CliUtils

  attr_accessor :profile, :ssh_key

  # AWS related configs are saved under .aws directory by default

  def initialize
    conf_file = "#{File.dirname(__FILE__)}/aws.yml"
    raise "Missing config file aws.yml under #{File.dirname(__FILE__)}" unless File.file?(conf_file)
    conf = YAML.load_file(conf_file)
    conf['accounts'].each do |account|
      @accts = {} unless @accts
      @accts[account] = {}
      @accts[account][:ssh_key] = conf['profiles'][account]['ssh_key']
      @accts[account][:profile] = conf['profiles'][account]['name']
    end
  end

  def select_acct
    acct_name, acct_detail = create_options('aws profile', @accts) { |acct, details| "#{acct}\n" }

    @ssh_key = acct_detail[:ssh_key]
    @ssh_key = "#{ENV['HOME']}/.ssh/#{@ssh_key}" unless File.file?(@ssh_key)
    raise "Unable to find ssh key: #{@ssh_key}" unless File.file?(@ssh_key)

    @profile = acct_detail[:profile]
    self
  end
end
