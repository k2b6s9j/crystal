class File < FileDescriptorIO

  # The file/directory separator character. '/' in unix, '\\' in windows.
  SEPARATOR = ifdef darwin || linux; '/'; elsif windows; '\\'; end

  # The file/directory separator string. "/" in unix, "\\" in windows.
  SEPARATOR_STRING = ifdef darwin || linux; "/"; elsif windows; "\\"; end

  # The path separator character.  ':' in unix, ';' in windows.
  PATH_SEPARATOR = ifdef darwin || linux; ':'; elsif windows; ';'; end

  # :nodoc:
  DEFAULT_CREATE_MODE = ifdef darwin || linux; LibC::S_IRUSR | LibC::S_IWUSR | LibC::S_IRGRP | LibC::S_IROTH; elsif windows; LibC::S_IRUSR | LibC::S_IWUSR; end

  def initialize(filename, mode = "r")
    oflag = open_flag(mode)

    ifdef darwin || linux
        fd = LibC.open(filename, oflag, DEFAULT_CREATE_MODE)
      elsif windows
        fd = LibC.wopen(filename.to_utf16, oflag, DEFAULT_CREATE_MODE)
      end
    if fd < 0
      raise Errno.new("Error opening file '#{filename}' with mode '#{mode}'")
    end

    @path = filename
    super(fd, blocking: true)
  end

  protected def open_flag(mode)
    if mode.length == 0
      raise "invalid access mode #{mode}"
    end

    m = 0
    o = 0
    case mode[0]
    when 'r'
      m = LibC::O_RDONLY
    when 'w'
      m = LibC::O_WRONLY
      o = LibC::O_CREAT | LibC::O_TRUNC
    when 'a'
      m = LibC::O_WRONLY
      o = LibC::O_CREAT | LibC::O_APPEND
    else
      raise "invalid access mode #{mode}"
    end

    case mode.length
    when 1
      # Nothing
    when 2
      case mode[1]
      when '+'
        m = LibC::O_RDWR
      when 'b'
        # Nothing
      else
        raise "invalid access mode #{mode}"
      end
    else
      raise "invalid access mode #{mode}"
    end

    oflag = m | o
  end

  getter path

  def self.stat(path)
    ifdef darwin || linux
      status = LibC.stat(path, out stat)
    elsif windows
      status = LibC.wstat(path.to_utf16, out stat)
    end
    if status != 0
      raise Errno.new("Unable to get stat for '#{path}'")
    end
    Stat.new(stat)
  end

  def self.lstat(path)
    ifdef darwin || linux
      status = LibC.lstat(path, out stat)
    elsif windows
      status = LibC.wstat(path.to_utf16, out stat)
    end
    if status != 0
      raise Errno.new("Unable to get lstat for '#{path}'")
    end
    Stat.new(stat)
  end

  def self.exists?(filename)
    ifdef darwin || linux
      LibC.access(filename, LibC::F_OK) == 0
    elsif windows
      LibC.waccess(filename.to_utf16, LibC::F_OK) == 0
    end
  end

  def self.file?(path)
    ifdef darwin || linux
      status = LibC.stat(path, out stat)
    elsif windows
      status = LibC.wstat(path.to_utf16, out stat)
    end
    if status != 0
      return false
    end
    Stat.new(stat).file?
  end

  def self.directory?(path)
    Dir.exists?(path)
  end

  def self.dirname(filename)
    ifdef darwin || linux
      index = filename.rindex('/')
      if index
        if index == 0
          "/"
        else
          filename[0, index]
        end
      else
        "."
      end
    elsif windows
      drive :: UInt16[3]
      buf :: UInt16[256]
      LibC.wsplitpath(filename.to_utf16, drive, buf, nil, nil)
      dir = String.new(drive.buffer) + String.new(buf.buffer)
      dir = dir[0...dir.length - 1] if dir.ends_with?('\\')
      dir
    end
  end

  def self.basename(filename)
    return "" if filename.bytesize == 0

    ifdef darwin || linux
      last = filename.length - 1
      last -= 1 if filename[last] == '/'

      index = filename.rindex('/', last)
      if index
        filename[index + 1, last - index]
      else
        filename
      end
    elsif windows
      buf :: UInt16[256]
      LibC.wsplitpath(filename.to_utf16, nil, nil, buf, nil)
      String.new buf.buffer
    end
  end

  def self.basename(filename, suffix)
    basename = basename(filename)
    basename = basename[0, basename.length - suffix.length] if basename.ends_with?(suffix)
    basename
  end

  def self.delete(filename)
    ifdef darwin || linux
      err = LibC.unlink(filename)
    elsif windows
      err = LibC.wunlink(filename.to_utf16)
    end
    if err == -1
      raise Errno.new("Error deleting file '#{filename}'")
    end
  end

  def self.extname(filename)
    ifdef darwin || linux
      dot_index = filename.rindex('.')

      if dot_index && dot_index != filename.length - 1  && filename[dot_index - 1] != '/'
        filename[dot_index, filename.length - dot_index]
      else
        ""
      end
    elsif windows
      buf :: UInt16[256]
      LibC.wsplitpath(filename.to_utf16, nil, nil, nil, buf)
      String.new buf.buffer
    end
  end

  def self.expand_path(path, dir = nil)
    ifdef darwin || linux
      if path.starts_with?('~')
        home = ENV["HOME"]
        if path.length >= 2 && path[1] == '/'
          path = home + path[1..-1]
        elsif path.length < 2
          return home
        end
      end

      unless path.starts_with?('/')
        dir = dir ? expand_path(dir) : Dir.working_directory
        path = "#{dir}/#{path}"
      end

      parts = path.split('/')
      was_letter = false
      first_slash = true
      items = [] of String
      parts.each do |part|
        if part.empty? && !was_letter
          items << part if !first_slash
        elsif part == ".."
          items.pop if items.size > 0
        elsif !part.empty? && part != "."
          was_letter = true
          items << part
        end
      end

      String.build do |str|
        str << "/"
        items.join "/", str
      end
    elsif windows
      if dir
        path = "#{dir}\\#{path}" unless path.length >= 2 && path[1] == ':'
      end

      fullpath = LibC.wfullpath(nil, path.to_utf16, LibC::SizeT.cast(0))
      String.new(fullpath).tap { LibC.free(fullpath as Void*) }
    end
  end

  def self.open(filename, mode = "r")
    new filename, mode
  end

  def self.open(filename, mode = "r")
    file = File.new filename, mode
    begin
      yield file
    ensure
      file.close
    end
  end

  def self.read(filename)
    File.open(filename, "r") do |file|
      size = file.size.to_i
      String.new(size) do |buffer|
        file.read Slice.new(buffer, size)
        {size.to_i, 0}
      end
    end
  end

  def self.each_line(filename)
    File.open(filename, "r") do |file|
      buffered_io = BufferedIO.new(file)
      buffered_io.each_line do |line|
        yield line
      end
    end
  end

  def self.read_lines(filename)
    lines = [] of String
    each_line(filename) do |line|
      lines << line
    end
    lines
  end

  def self.write(filename, content)
    File.open(filename, "w") do |file|
      file.print(content)
    end
  end

  # Returns a new string formed by joining the strings using File::SEPARATOR.
  #
  # ```
  # File.join("foo", "bar", "baz") #=> "foo/bar/baz"
  # File.join("foo/", "/bar/", "/baz") #=> "foo/bar/baz"
  # File.join("/foo/", "/bar/", "/baz/") #=> "/foo/bar/baz/"
  # ```
  def self.join(*parts)
    join parts
  end

  # Returns a new string formed by joining the strings using File::SEPARATOR.
  #
  # ```
  # File.join("foo", "bar", "baz") #=> "foo/bar/baz"
  # File.join("foo/", "/bar/", "/baz") #=> "foo/bar/baz"
  # File.join("/foo/", "/bar/", "/baz/") #=> "/foo/bar/baz/"
  # ```
  def self.join(parts : Array | Tuple)
    String.build do |str|
      parts.each_with_index do |part, index|
        str << SEPARATOR if index > 0

        byte_start = 0
        byte_count = part.bytesize

        if index > 0 && part.starts_with?(SEPARATOR)
          byte_start += 1
          byte_count -= 1
        end

        if index != parts.length - 1 && part.ends_with?(SEPARATOR)
          byte_count -= 1
        end

        str.write part.unsafe_byte_slice(byte_start, byte_count)
      end
    end
  end

  def self.size(filename)
    stat(filename).size
  end

  def self.rename(old_filename, new_filename)
    ifdef darwin || linux
      status = LibC.rename(old_filename, new_filename)
    elsif windows
      File.delete(new_filename) if File.exists?(new_filename)
      status = LibC.wrename(old_filename.to_utf16, new_filename.to_utf16)
    end
    if status != 0
      raise Errno.new("Error renaming file '#{old_filename}' to '#{new_filename}'")
    end
    status
  end

  def size
    stat.size
  end

  def to_s(io)
    io << "#<File:" << @path
    io << " (closed)" if closed?
    io << ">"
    io
  end
end

require "file/stat"
