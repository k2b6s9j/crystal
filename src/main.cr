lib LibCrystalMain
  @[Raises]
  fun __crystal_main(argc : Int32, argv : UInt8**)
end

# :nodoc:
module AtExitHandlers
  @@handlers = nil

  def self.add(handler)
    handlers = @@handlers ||= [] of ->
    handlers << handler
  end

  def self.run
    return if @@running
    @@running = true

    begin
      @@handlers.try &.each &.call
    rescue handler_ex
      puts "Error running at_exit handler: #{handler_ex}"
    end
  end
end

def at_exit(&handler)
  AtExitHandlers.add(handler)
end

def exit(status = 0)
  AtExitHandlers.run
  Process.exit(status)
end

def abort(message, status = 1)
  puts message
  exit status
end

ifdef darwin || linux
  STDIN = BufferedIO.new(FileDescriptorIO.new(0, blocking: LibC.isatty(0) == 0))
  STDOUT = AutoflushBufferedIO.new(FileDescriptorIO.new(1, blocking: LibC.isatty(1) == 0))
  STDERR = BufferedIO.new(FileDescriptorIO.new(2, blocking: LibC.isatty(2) == 0))
elsif windows
  class ANSIEscFileDescriptorIO < FileDescriptorIO
    def write(slice : Slice(UInt8), count)
      str = String.new(slice.pointer(count), count) # win32: remove string creation
      return super unless tty? && str.includes?("\e[")
      win32_colormap = [
        0,
        LibWin32::FOREGROUND_RED,
        LibWin32::FOREGROUND_GREEN,
        LibWin32::FOREGROUND_RED | LibWin32::FOREGROUND_GREEN,
        LibWin32::FOREGROUND_BLUE,
        LibWin32::FOREGROUND_RED | LibWin32::FOREGROUND_BLUE,
        LibWin32::FOREGROUND_GREEN | LibWin32::FOREGROUND_BLUE,
        LibWin32::FOREGROUND_RED | LibWin32::FOREGROUND_GREEN | LibWin32::FOREGROUND_BLUE,
      ]
      LibWin32.getconsolescreenbufferinfo(handle, out default)
      len = str.length
      p = 0
      while true
        v = [-1]
        q = str.index("\e[", p)
        break unless q
        super str[p...q].to_slice
        q += 2
        len -= q - p
        while len > 0
          c = str[q]
          q += 1
          len -= 1
          case c
          when .digit?
            v[-1] = ((v[-1] != -1) ? v[-1] * 10 : 0) + c.ord - '0'.ord
          when .== ';'
            v.push(-1)
          when .in_set?(">=?")
            m = c
          else
            break
          end
        end
        case c
        when 'm'
          LibWin32.getconsolescreenbufferinfo(handle, out last)
          fore = last.wattributes & LibWin32::FOREGROUND_MASK
          back = last.wattributes & LibWin32::BACKGROUND_MASK
          v.each do |v|
            next if v == -1
            case v
            when 39
              fore = default.wattributes & LibWin32::FOREGROUND_MASK
            when 49
              back = default.wattributes & LibWin32::BACKGROUND_MASK
            when 30..37
              fore = win32_colormap[v - 30]
            when 90..97
              fore = win32_colormap[v - 90] | LibWin32::FOREGROUND_INTENSITY
            when 40..47
              back = win32_colormap[v - 40] << 4
            when 100..107
              back = win32_colormap[v - 100] << 4 | LibWin32::BACKGROUND_INTENSITY
            when 0
              fore = default.wattributes & LibWin32::FOREGROUND_MASK
              back = default.wattributes & LibWin32::BACKGROUND_MASK
            end
          end
          LibWin32.setconsoletextattribute(handle, (fore | back).to_u16)
        end
        p = q
      end
      super str[p..-1].to_slice
    end
  end

  STDIN = BufferedIO.new(FileDescriptorIO.new(0, blocking: LibC.isatty(0) == 0))
  STDOUT = AutoflushBufferedIO.new(ANSIEscFileDescriptorIO.new(1, blocking: LibC.isatty(1) == 0))
  STDERR = BufferedIO.new(ANSIEscFileDescriptorIO.new(2, blocking: LibC.isatty(2) == 0))
end

ifdef darwin || linux
  macro redefine_main(name = main)
    fun main = {{name}}(argc : Int32, argv : UInt8**) : Int32
      GC.init
      {{yield LibCrystalMain.__crystal_main(argc, argv)}}
      0
    rescue ex
      puts "#{ex} (#{ex.class})"
      ex.backtrace.each do |frame|
        puts frame
      end
      1
    ensure
      AtExitHandlers.run
    end
  end
elsif windows
  # win32: TODO: exceptions, AtExitHandlers, ...
  macro redefine_main(name = main)
    fun main = {{name}}(argc : Int32, argv : UInt8**) : Int32
      GC.init
      {{yield LibCrystalMain.__crystal_main(argc, argv)}}
      0
    end
  end
end

redefine_main do |main|
  {{main}}
end
