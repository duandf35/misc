require_relative 'color'

module CliUtils
  include Color

  module_function

  # `history` not work because 'history' is not an Unix executable file but
  # a built-in function of bash
  #
  # an alternative way to update the bash history is appending line to the
  # '.bash_history' file, but to make the file sync with the current bash
  # session, the following line must be added into the '.bashrc' file:
  #
  #     export PROMPT_COMMAND="history -a; history -n"
  #
  def append_to_bash_history(cmd)
    File.open(ENV['HOME'] + '/.bash_history', 'a') {|f| f << cmd + "\n"}
  end

  # filter will return true if element match any of the regexs
  def create_filter(regexs, field = nil)
    return nil if regexs.nil? || regexs.empty?

    # /<regex>/i match pattern ignore case
    proc { |e| regexs.index do |regex|
      return /#{regex}/i =~ e if field
      return /#{regex}/i =~ e[field] if field
    end }
  end

  def filter(results, &filter)
    return results unless filter

    results.find_all {|e| filter.call(e)}
  end

  def create_options(target_name, collection, &desc)
    prompt = "Select #{target_name}:\n"

    # empty array is truthy in ruby
    raise 'No option available!' if collection.nil? || collection.empty?

    id = 0
    option_hash = {}
    collection.each do |entry|
      # if the collection is a hash then the entry would be an array
      # with the key as the first element and the value as the second element
      option_hash[id.to_s.to_sym] = entry
      prompt += "#{id}) "
      prompt += desc.call(entry)
      id += 1
    end

    puts prompt

    option_id = gets.strip

    raise 'Invalid input!' if option_id !~ /\A\d+\z/ || option_hash[option_id.to_s.to_sym].nil?

    option_hash[option_id.to_s.to_sym]
  end

  # spawn(cmd)
  # will create subprocess instead of replace the existing one
  #
  # Process.detach(spawn(cmd))
  # doesn't work on OSX which cause the spawned process to be an orphan process
  # and the orphan process cause the ssh command to return 'tcsetattr: Input/output error'
  #
  # Process.wait(spawn(cmd))
  # will let the ruby process keep running util the subprocess return an exit status
  #
  # Process.exec(cmd)
  # will replace the current process by running the given command
  def exec(cmd)
    puts g(cmd)

    Process.exec(cmd)
  end

  def read_cache(path, prefix, profile, &mapper)
    cached_instance_list = []
    cache_file = "#{path}/#{prefix}-#{profile}.csv"
    return cached_instance_list unless File.file?(cache_file)
    File.open(cache_file, 'r') do |f|
      f.each_line do |instance|
        props = instance.strip.split(',')
        cached_instance_list << mapper.call(props)
      end
    end
    cached_instance_list
  end

  def write_cache(instance_list, path, prefix, profile)
    return if instance_list.empty?
    File.open("#{path}/#{prefix}-#{profile}.csv", 'w') do |f|
      instance_list.each {|instance| f.write("#{instance.values.join(',')}\n")}
    end
  end
end
