require "./ip_socket"

class UDPSocket < IPSocket
  def initialize(family = Socket::Family::INET : Socket::Family)
    super LibC.socket(family.value, LibC::SOCK_DGRAM, LibC::IPPROTO_UDP).tap do |sock|
      raise Errno.new("Error opening socket") if sock <= 0
    end
  end

  def bind(host, port)
    getaddrinfo(host, port, nil, LibC::SOCK_DGRAM, LibC::IPPROTO_UDP) do |ai|
      optval = 1
      LibC.setsockopt(fd, LibC::SOL_SOCKET, LibC::SO_REUSEADDR, pointerof(optval) as Void*, sizeof(Int32))

      ifdef darwin || linux
        status = LibC.bind(fd, ai.addr, ai.addrlen)
      elsif windows
        status = LibC.bind(fd, ai.addr, ai.addrlen.to_i32)
      end
      if status != 0
        next false if ai.next
        raise Errno.new("Error binding UDP socket at #{host}:#{port}")
      end

      true
    end
  end

  def connect(host, port)
    getaddrinfo(host, port, nil, LibC::SOCK_DGRAM, LibC::IPPROTO_UDP) do |ai|
      ifdef darwin || linux
        status = LibC.connect(fd, ai.addr, ai.addrlen)
      elsif windows
        status = LibC.connect(fd, ai.addr, ai.addrlen.to_i32)
      end
      if status != 0
        next false if ai.next
        raise Errno.new("Error connecting UDP socket at #{host}:#{port}")
      end

      true
    end
  end
end
