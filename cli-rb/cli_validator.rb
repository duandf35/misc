module CliValidator

  module_function

  def next?(argv, err)
    return argv.shift if argv.any?
    raise err
  end
end
