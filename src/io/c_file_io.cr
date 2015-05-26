lib LibC
  ifdef darwin || linux
    type File = Void*
  elsif windows
    struct IoBuf
      ptr : UInt8*
      cnt : Int32
      base : UInt8*
      flag : Int32
      file : Int32
      charbuf : Int32
      bufsiz : Int32
      tmpfname : UInt8*
    end

    type File = IoBuf*
  end

  fun fopen(filename : UInt8*, mode : UInt8*) : File
  fun fread(buffer : UInt8*, size : SizeT, nitems : SizeT, file : File) : SizeT
  fun fwrite(buf : UInt8*, size : SizeT, count : SizeT, fp : File) : SizeT
  fun fclose(file : File) : Int32
  fun feof(file : File) : Int32
  fun fflush(file : File) : Int32
  fun rename(oldname : UInt8*, newname : UInt8*) : Int32

  ifdef darwin || linux
    fun access(filename : UInt8*, how : Int32) : Int32
    fun fileno(file : File) : Int32
    fun unlink(filename : UInt8*) : Int32
    fun popen(command : UInt8*, mode : UInt8*) : File
    fun pclose(stream : File) : Int32
    fun realpath(path : UInt8*, resolved_path : UInt8*) : UInt8*

    ifdef x86_64
      fun fseeko(file : File, offset : Int64, whence : Int32) : Int32
      fun ftello(file : File) : Int64
    else
      fun fseeko = fseeko64(file : File, offset : Int64, whence : Int32) : Int32
      fun ftello = ftello64(file : File) : Int64
    end

    fun getdelim(linep : UInt8**, linecapp : SizeT*, delimiter : Int32, stream : File) : SSizeT

    ifdef darwin
      $stdin = __stdinp : File
      $stdout = __stdoutp : File
      $stderr = __stderrp : File
    elsif linux
      $stdin : File
      $stdout : File
      $stderr : File
    end
  elsif windows
    fun wrename = _wrename(oldname : UInt16*, newname : UInt16*) : Int32
    fun wfopen = _wfopen(filename : UInt16*, mode : UInt16*) : File
    fun waccess = _waccess(filename : UInt16*, how : Int32) : Int32
    fun fileno = _fileno(file : File) : Int32
    fun wunlink = _wunlink(filename : UInt16*) : Int32
    fun wpopen = _wpopen(command : UInt16*, mode : UInt8*) : File
    fun pclose = _pclose(stream : File) : Int32
    fun wfullpath = _wfullpath(buf : UInt16*, path : UInt16*, size : SizeT) : UInt16*

    fun fseeko = _fseeki64(file : File, offset : Int64, origin : Int32) : Int32
    fun ftello = _ftelli64(file : File) : Int64

    fun get_osfhandle = _get_osfhandle(fd : Int32) : IntT
    fun iob_func = __iob_func : File
  end

  SEEK_SET = 0
  SEEK_CUR = 1
  SEEK_END = 2

  F_OK = 0
  X_OK = 1 << 0
  W_OK = 1 << 1
  R_OK = 1 << 2
end

struct CFileIO
  include IO

  def initialize(@file)
  end

  def read(slice : Slice(UInt8), count)
    LibC.fread(slice.pointer(count), LibC::SizeT.cast(1), LibC::SizeT.cast(count), @file)
  end

  def write(slice : Slice(UInt8), count)
    LibC.fwrite(slice.pointer(count), LibC::SizeT.cast(1), LibC::SizeT.cast(count), @file)
  end

  ifdef darwin || linux
    def gets(delimiter = '\n' : Char)
      if delimiter.ord >= 128
        return super
      end

      linep = Pointer(UInt8).null
      linecapp = LibC::SizeT.zero

      written = LibC.getdelim(pointerof(linep), pointerof(linecapp), delimiter.ord, @file)
      return nil if written == -1

      String.new Slice.new(linep, written.to_i32)
    end
  elsif windows
    # win32: TODO
  end

  def flush
    LibC.fflush @file
  end

  def close
    LibC.fclose @file
  end

  def fd
    LibC.fileno @file
  end

  ifdef windows
    def handle
      LibC.get_osfhandle fd
    end
  end

  def tty?
    LibC.isatty(fd) != 0
  end

  def to_fd_io
    FileDescriptorIO.new fd
  end
end

ifdef darwin || linux
  STDIN = CFileIO.new(LibC.stdin)
  STDOUT = CFileIO.new(LibC.stdout)
  STDERR = CFileIO.new(LibC.stderr)
elsif windows
  struct ANSIEscCFileIO < CFileIO
    def <<(obj)
      return super unless tty? && obj.to_s.includes?("\e[")
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
      str = obj.to_s
      len = str.length
      p = 0
      while true
        v = [-1]
        q = str.index("\e[", p)
        break unless q
        super str[p...q]
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
      super str[p..-1]
    end
  end

  STDIN = CFileIO.new(LibC.iob_func)
  STDOUT = ANSIEscCFileIO.new(LibC.iob_func + 1)
  STDERR = ANSIEscCFileIO.new(LibC.iob_func + 2)
end
