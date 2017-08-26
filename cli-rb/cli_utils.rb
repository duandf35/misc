require_relative 'color'

module CliUtils

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

    # 'unless collection' doesn't work since empty collection in ruby is truthy
    if collection.nil? || collection.empty?
      puts 'No option available!'
      exit(1)
    end

    return collection[0] if collection.length == 1

    id = 0
    collection.each do |entry|
      prompt += "#{id}) "
      prompt += desc.call(entry)
      id += 1
    end

    puts prompt

    option_id = gets.strip

    if option_id !~ /\A\d+\z/ || collection[option_id.to_i].nil?
      puts 'Invalid input!'
      exit 1
    end

    collection[option_id.to_i]
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
    puts Color.g(cmd)

    Process.exec(cmd)
  end
end
