module CliUtils

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
    File.open(ENV['HOME'] + '/.bash_history', 'a') { |f| f << cmd + "\n" }
  end

  # filter will return true if element match any of the regexs
  def create_filter(regexs)
    return nil if regexs.nil? || regexs.empty?

    # /<regex>/i match pattern ignore case
    proc { |e| regexs.index { |regex| /#{regex}/i =~ e } }
  end

  def filter(results, field = nil, &filter)
    return results unless filter

    results.find_all do |e|
      if field
        filter.call(e[field])
      else
        filter.call(e)
      end
    end
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
    puts cmd

    Process.exec(cmd)
  end
end
