module Color

  module_function

  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def r(text); colorize(text, 31); end # red
  def g(text); colorize(text, 32); end # green
  def y(text); colorize(text, 33); end # yellow
end
