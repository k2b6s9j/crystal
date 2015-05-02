require "./libc"

lib LibC
  ifdef darwin
    struct Addrinfo
      flags : Int32
      family : Int32
      socktype : Int32
      protocol : Int32
      addrlen : Int32
      canonname : UInt8*
      addr : SockAddr*
      next : Addrinfo*
    end
  elsif linux
    struct Addrinfo
      flags : Int32
      family : Int32
      socktype : Int32
      protocol : Int32
      addrlen : Int32
      addr : SockAddr*
      canonname : UInt8*
      next : Addrinfo*
    end
  elsif windows
    struct Addrinfo
      flags : Int32
      family : Int32
      socktype : Int32
      protocol : Int32
      addrlen : SizeT
      canonname : UInt8*
      addr : SockAddr*
      next : Addrinfo*
    end
  end

  ifdef darwin || linux
    fun freeaddrinfo(addr : Addrinfo*) : Void
    fun gai_strerror(code : Int32) : UInt8*
    fun getaddrinfo(name : UInt8*, service : UInt8*, hints : Addrinfo*, pai : Addrinfo**) : Int32
    fun getnameinfo(addr : SockAddr*, addrlen : Int32, host : UInt8*, hostlen : Int32, serv : UInt8*, servlen : Int32, flags : Int32) : Int32
  elsif windows
    @[CallConvention("X86_StdCall")]
    fun freeaddrinfo(addr : Addrinfo*) : Void
    @[CallConvention("X86_StdCall")]
    fun getaddrinfo(name : UInt8*, service : UInt8*, hints : Addrinfo*, pai : Addrinfo**) : Int32
    @[CallConvention("X86_StdCall")]
    fun getnameinfo(addr : SockAddr*, addrlen : Int32, host : UInt8*, hostlen : Int32, serv : UInt8*, servlen : Int32, flags : Int32) : Int32
  end

  AI_PASSIVE = 0x0001
  AI_CANONNAME = 0x0002
  AI_NUMERICHOST = 0x0004
  AI_V4MAPPED = 0x0008
  AI_ALL = 0x0010
  AI_ADDRCONFIG = 0x0020

  NI_MAXHOST = 1025
  NI_MAXSERV = 32

  NI_NUMERICHOST = 1
  NI_NUMERICSERV = 2
  NI_NOFQDN = 4
  NI_NAMEREQD = 8
  NI_DGRAM = 16
end

def gai_strerror(code : Int32)
  ifdef darwin || linux
    String.new(gai_strerror(code))
  elsif windows
    msg :: UInt16[1024]
    flags = (LibWin32::FORMAT_MESSAGE_FROM_SYSTEM | LibWin32::FORMAT_MESSAGE_IGNORE_INSERTS | LibWin32::FORMAT_MESSAGE_MAX_WIDTH_MASK).to_u32
    languageid = (LibWin32::LANG_NEUTRAL | LibWin32::SUBLANG_DEFAULT << 10).to_u32
    LibWin32.wformatmessage(flags, nil, code.to_u32, languageid, msg, 1024_u32, nil)
    String.new msg.buffer
  end
end
