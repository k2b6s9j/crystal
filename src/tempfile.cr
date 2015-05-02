lib LibC
  ifdef darwin || linux
    fun mkstemp(result : UInt8*) : Int32
  elsif windows
    fun wmktemp = _wmktemp(filename : UInt16*) : UInt16*
  end
end

class Tempfile < FileDescriptorIO
  def initialize(name)
    ifdef darwin || linux
      if tmpdir = ENV["TMPDIR"]?
        tmpdir = tmpdir + '/' unless tmpdir.ends_with?('/')
      else
        tmpdir = "/tmp/"
      end
      @path = "#{tmpdir}#{name}.XXXXXX"
      super(LibC.mkstemp(@path), blocking: true)
    elsif windows
      if tmpdir = ENV["TEMP"]?
        tmpdir = tmpdir + '\\' unless tmpdir.ends_with?('\\')
      else
        tmpdir = ""
      end

      path = LibC.wmktemp("#{tmpdir}#{name}.XXXXXX".to_utf16)

      fd = LibC.wopen(path, LibC::O_RDWR | LibC::O_CREAT | LibC::O_TRUNC, File::DEFAULT_CREATE_MODE)
      if fd < 0
        raise Errno.new("Error opening tempfile '#{path}'")
      end

      @path = String.new(path)
      super(fd, blocking: true)
    end
  end

  getter path

  def self.open(filename)
    tempfile = Tempfile.new(filename)
    begin
      yield tempfile
    ensure
      tempfile.close
    end
    tempfile
  end

  def delete
    File.delete @path
  end

  def unlink
    delete
  end
end
