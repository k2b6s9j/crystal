struct TimeFormat
  ISO_8601_DATE = new "%F"

  class Error < ::Exception
  end

  getter pattern

  def initialize(@pattern : String)
  end

  def parse(string, kind = Time::Kind::Unspecified)
    parser = Parser.new(string)
    parser.visit(pattern)
    parser.time(kind)
  end

  def format(time : Time)
    String.build do |str|
      format time, str
    end
  end

  def format(time : Time, io : IO)
    formatter = Formatter.new(time, io)
    formatter.visit(pattern)
    io
  end
end
