class StringScanner
  def initialize(@str)
    @offset = 0
  end

  def scan(re)
    match = re.match(@str, @offset, Regex::Options::ANCHORED)
    if match
      @offset = match.end(0).to_i
      match[0]
    else
      nil
    end
  end

  def eos?
    @offset >= @str.length
  end

  def rest
    @str[@offset, @str.length - @offset]
  end
end
