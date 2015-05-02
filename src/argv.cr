lib LibC
  struct StartupInfo
    newmode : Int32
  end

  fun wgetmainargs = __wgetmainargs(argc : Int32*, argv : UInt16***, env : UInt16***, glob : Int32, info : StartupInfo*)
end

ifdef darwin || linux
  PROGRAM_NAME = String.new(ARGV_UNSAFE.value)
  ARGV = (ARGV_UNSAFE + 1).to_slice(ARGC_UNSAFE - 1).map { |c_str| String.new(c_str) }
 elsif windows
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
