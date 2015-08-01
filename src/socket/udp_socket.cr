require "./ip_socket"

# A User Datagram Protocol socket.
# UDP runs on top of the Internet Protocol (IP) and was developed for applications that do
# not require reliability, acknowledgement, or flow control features at the transport layer.
# This simple protocol provides transport layer addressing in the form of UDP ports and an
# optional checksum capability.
#
# UDP is a very simple protocol. Messages, so called datagrams, are sent to other hosts on
# an IP network without the need to set up special transmission channels or data paths
# beforehand. The UDP socket only needs to be opened for communication. It listens for
# incoming messages and sends outgoing messages on request.
#
# This implementation supports both IPv4 and IPv6 addresses. For IPv4 addresses you need use
# `Socket::Family::INET` family (used by default). And `Socket::Family::INET6` for IPv6
# addresses accordingly.
#
# Usage example:
# ```
# require "socket"
#
# # Create server
# server = UDPSocket.new
# server.bind "localhost", 1234
#
# # Create client and connect to server
# client = UDPSocket.new
# client.connect "localhost", 1234
#
# client << "message" # send message to server
# server.read(7)      # => "message"
#
# # Close client and server
# client.close
# server.close
# ```
class UDPSocket < IPSocket
  def initialize(family = Socket::Family::INET : Socket::Family)
    super LibC.socket(family.value, LibC::SOCK_DGRAM, LibC::IPPROTO_UDP).tap do |sock|
      raise Errno.new("Error opening socket") if sock <= 0
    end
  end

  # Creates a UDP socket from the given address.
  #
  # ```
  # server = UDPSocket.new
  # server.bind "localhost", 1234
  # ```
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

  # Attempts to connect the socket to a remote address and port for this socket.
  #
  # ```
  # client = UDPSocket.new
  # client.connect "localhost", 1234
  # ```
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
