module Benchmark
  extend self

  # :nodoc:
  class Tms
    getter utime
    getter stime
    getter cutime
    getter cstime
    getter real
    getter label

    def initialize(@utime, @stime, @cutime, @cstime, @real, @label)
    end

    def total
      utime + stime + cutime + cstime
    end

    def to_s(io : IO)
      io.printf "  %.6f   %.6f   %.6f (  %.6f)", utime, stime, total, real
    end
  end

  # :nodoc:
  class Report
    def initialize
      @reports = [] of {String, ->}
      @label_width = 0
    end

    def report(label = " ", &block)
      @label_width = label.length if label.length > @label_width
      @reports << {label, block}
    end

    def execute
      if @label_width > 0
        print " " * @label_width
      end
      puts "       user     system      total        real"

      @reports.each do |report|
        label, block = report
        print label
        diff = @label_width - label.length + 1
        if diff > 0
          print " " * diff
        end
        print Benchmark.measure(label, &block)
        puts
      end
    end
  end

  def measure(label = "")
    t0, r0 = Process.times, Time.now
    yield
    t1, r1 = Process.times, Time.now
    Tms.new(t1.utime  - t0.utime,
                     t1.stime  - t0.stime,
                     t1.cutime - t0.cutime,
                     t1.cstime - t0.cstime,
                     (r1.ticks - r0.ticks).to_f / TimeSpan::TicksPerSecond,
                     label)
  end

  def realtime
    r0 = Time.now
    yield
    Time.now - r0
  end

  def bm
    report = Report.new
    yield report
    report.execute
    report
  end
end
