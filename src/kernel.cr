lib LibC
  struct StartupInfo
    newmode : Int32
  end

  fun wgetmainargs = __wgetmainargs(argc : Int32*, argv : UInt16***, env : UInt16***, glob : Int32, info : StartupInfo*)
end

ifdef darwin || linux
  STDIN = BufferedIO.new(FileDescriptorIO.new(0, blocking: LibC.isatty(0) == 0, edge_triggerable: ifdef darwin; false; else; true; end))
  STDOUT = AutoflushBufferedIO.new(FileDescriptorIO.new(1, blocking: LibC.isatty(1) == 0, edge_triggerable: ifdef darwin; false; else; true; end))
  STDERR = FileDescriptorIO.new(2, blocking: LibC.isatty(2) == 0, edge_triggerable: ifdef darwin; false; else; true; end)

  PROGRAM_NAME = String.new(ARGV_UNSAFE.value)
  ARGV = (ARGV_UNSAFE + 1).to_slice(ARGC_UNSAFE - 1).map { |c_str| String.new(c_str) }
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

  STDIN = BufferedIO.new(FileDescriptorIO.new(0, blocking: LibC.isatty(0) == 0, edge_triggerable: ifdef darwin; false; else; true; end))
  STDOUT = AutoflushBufferedIO.new(ANSIEscFileDescriptorIO.new(1, blocking: LibC.isatty(1) == 0, edge_triggerable: ifdef darwin; false; else; true; end))
  STDERR = ANSIEscFileDescriptorIO.new(2, blocking: LibC.isatty(2) == 0, edge_triggerable: ifdef darwin; false; else; true; end)

  PROGRAM_PATH = begin
    buf :: UInt16[LibC::MAX_PATH]
    LibWin32.wgetmodulefilename(LibC::IntT.cast(0), buf.buffer, 260_u32)
    String.new(buf.buffer)
  end

  ARGVF = begin
    info :: LibC::StartupInfo
    info.newmode = 0
    LibC.wgetmainargs(out argc, out argv, out env, 1, pointerof(info))
    argv.to_slice(argc).map { |wcs| String.new(wcs) }
  end

  PROGRAM_NAME = ARGVF[0]
  ARGV = ARGVF[1..-1]
end

def loop
  while true
    yield
  end
end

def gets
  STDIN.gets
end

def gets(delimiter : Char)
  STDIN.gets(delimiter)
end

def gets(delimiter : String)
  STDIN.gets(delimiter)
end

def read_line
  STDIN.read_line
end

def read_line(delimiter : Char)
  STDIN.read_line(delimiter)
end

def read_line(delimiter : String)
  STDIN.read_line(delimiter)
end

def print(*objects : _)
  STDOUT.print *objects
end

def print!(*objects : _)
  print *objects
  STDOUT.flush
  nil
end

def printf(format_string, *args)
  printf format_string, args
end

def printf(format_string, args : Array | Tuple)
  STDOUT.printf format_string, args
end

def sprintf(format_string, *args)
  sprintf format_string, args
end

def sprintf(format_string, args : Array | Tuple)
  String.build(format_string.bytesize) do |str|
    String::Formatter.new(format_string, args, str).format
  end
end

def puts(*objects)
  STDOUT.puts *objects
end

def p(obj)
  obj.inspect(STDOUT)
  puts
  obj
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
  STDOUT.flush
  Process.exit(status)
end

def abort(message, status = 1)
  puts message
  exit status
end

Signal::PIPE.ignore
