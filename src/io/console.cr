lib LibTermios
  alias Cc = Char
  alias Tcflag = UInt64

  struct Struct
    iflag : Tcflag
    oflag : Tcflag
    cflag : Tcflag
    lflag : Tcflag
    cc : Cc*
  end

  enum OptionalActions
    TCSANOW
    TCSADRAIN
    TCSAFLUSH
  end

# The commented flags are not used yet and for many
# of them crossplatform availability is uncertain

  @[Flags]
  enum IFlag
#    IGNBRK  = 0000001
    BRKINT  = 0000002
#    IGNPAR  = 0000004
#    PARMRK  = 0000010
#    INPCK   = 0000020
    ISTRIP  = 0000040
#    INLCR   = 0000100
#    IGNCR   = 0000200
    ICRNL   = 0000400
#    IUCLC   = 0001000
    IXON    = 0002000
#    IXANY   = 0004000
#    IXOFF   = 0010000
#    IMAXBEL = 0020000
#    IUTF8   = 0040000
  end

  @[Flags]
  enum OFlag
    OPOST  = 0000001
#    OLCUC  = 0000002
#    ONLCR  = 0000004
#    OCRNL  = 0000010
#    ONOCR  = 0000020
#    ONLRET = 0000040
#    OFILL  = 0000100
#    OFDEL  = 0000200
##if defined __USE_MISC || defined __USE_XOPEN
#    NLDLY  = 0000400
#      NL0  = 0000000
#      NL1  = 0000400
#    CRDLY  = 0003000
#      CR0  = 0000000
#      CR1  = 0001000
#      CR2  = 0002000
#      CR3  = 0003000
#    TABDLY = 0014000
#      TAB0 = 0000000
#      TAB1 = 0004000
#      TAB2 = 0010000
#      TAB3 = 0014000
#    BSDLY  = 0020000
#      BS0  = 0000000
#      BS1  = 0020000
#    FFDLY  = 0100000
#      FF0  = 0000000
#      FF1  = 0100000
##endif
#    VTDLY  = 0040000
#      VT0  = 0000000
#      VT1  = 0040000
##ifdef __USE_MISC
#    XTABS  = 0014000
##endif
  end

#  enum CFlag
##ifdef __USE_MISC
#    CBAUD  = 0010017
##endif
#    B0     = 0000000     # hang up
#    B50    = 0000001
#    B75    = 0000002
#    B110   = 0000003
#    B134   = 0000004
#    B150   = 0000005
#    B200   = 0000006
#    B300   = 0000007
#    B600   = 0000010
#    B1200  = 0000011
#    B1800  = 0000012
#    B2400  = 0000013
#    B4800  = 0000014
#    B9600  = 0000015
#    B19200 = 0000016
#    B38400 = 0000017
##ifdef __USE_MISC
## define EXTA B19200
## define EXTB B38400
##endif
#    CSIZE    = 0000060
#    CS5      = 0000000
#    CS6      = 0000020
#    CS7      = 0000040
#    CS8      = 0000060
#    CSTOPB   = 0000100
#    CREAD    = 0000200
#    PARENB   = 0000400
#    PARODD   = 0001000
#    HUPCL    = 0002000
#    CLOCAL   = 0004000
##ifdef __USE_MISC
#    CBAUDEX  = 0010000
##endif
#    B57600   = 0010001
#    B115200  = 0010002
#    B230400  = 0010003
#    B460800  = 0010004
#    B500000  = 0010005
#    B576000  = 0010006
#    B921600  = 0010007
#    B1000000 = 0010010
#    B1152000 = 0010011
#    B1500000 = 0010012
#    B2000000 = 0010013
#    B2500000 = 0010014
#    B3000000 = 0010015
#    B3500000 = 0010016
#    B4000000 = 0010017
##define __MAX_BAUD B4000000
##ifdef __USE_MISC
#    CIBAUD   = 002003600000     # input baud rate (not used)
#    CMSPAR   = 010000000000     # mark or space (stick) parity
#    CRTSCTS  = 020000000000     # flow control
##endif
#  end

  @[Flags]
  enum LFlag
    ISIG    = 0000001
    ICANON  = 0000002
##if defined __USE_MISC || defined __USE_XOPEN
#    XCASE   = 0000004
##endif
    ECHO    = 0000010
    ECHOE   = 0000020
    ECHOK   = 0000040
    ECHONL  = 0000100
#    NOFLSH  = 0000200
#    TOSTOP  = 0000400
##ifdef __USE_MISC
#    ECHOCTL = 0001000
#    ECHOPRT = 0002000
#    ECHOKE  = 0004000
#    FLUSHO  = 0010000
#    PENDIN  = 0040000
##endif
    IEXTEN  = 0100000
#ifdef __USE_BSD
    EXTPROC = 0200000
#endif

  end

  fun cfmakeraw(termios_p : LibTermios::Struct*) : Int32
  fun tcgetattr(fd : Int32, termios_p : LibTermios::Struct*) : Int32
  fun tcsetattr(fd : Int32, optional_actions : OptionalActions, termios_p : LibTermios::Struct*) : Int32
end

struct CFileIO
  def cooked
    preserving_tc_mode("can't set IO#cooked") do |mode|
      cooked_from_tc_mode!
      yield self
    end
  end

  def cooked!
    if LibTermios.tcgetattr(fd, out mode) != 0
      raise Errno.new "can't set IO#cooked!"
    end
    cooked_from_tc_mode!
  end

  macro cooked_from_tc_mode!
    mode.iflag |= LibTermios::IFlag::BRKINT |
                  LibTermios::IFlag::ISTRIP |
                  LibTermios::IFlag::ICRNL  |
                  LibTermios::IFlag::IXON
    mode.oflag |= LibTermios::OFlag::OPOST
    mode.lflag |= LibTermios::LFlag::ECHO   |
                  LibTermios::LFlag::ECHOE  |
                  LibTermios::LFlag::ECHOK  |
                  LibTermios::LFlag::ECHONL |
                  LibTermios::LFlag::ICANON |
                  LibTermios::LFlag::ISIG   |
                  LibTermios::LFlag::IEXTEN
    LibTermios.tcsetattr(fd, LibTermios::OptionalActions::TCSANOW, pointerof(mode))
  end

  def raw
    preserving_tc_mode("can't set IO#raw") do |mode|
      raw_from_tc_mode!
      yield self
    end
  end

  def raw!
    if LibTermios.tcgetattr(fd, out mode) != 0
      raise Errno.new "can't set IO#raw!"
    end

    raw_from_tc_mode!
  end

  macro raw_from_tc_mode!
    LibTermios.cfmakeraw(pointerof(mode))
    LibTermios.tcsetattr(fd, LibTermios::OptionalActions::TCSANOW, pointerof(mode))
  end

  private def preserving_tc_mode(msg)
    if LibTermios.tcgetattr(fd, out mode) != 0
      raise Errno.new msg
    end
    before = mode
    begin
      yield mode
    ensure
      LibTermios.tcsetattr(fd, LibTermios::OptionalActions::TCSANOW, pointerof(before))
    end
  end

  ifdef darwin || linux
    def read_nonblock(length)
      before = LibC.fcntl(fd, LibC::FCNTL::F_GETFL)
      LibC.fcntl(fd, LibC::FCNTL::F_SETFL, before | LibC::O_NONBLOCK)

      begin
        String.new(length) do |buffer|
          read_length = read Slice.new(buffer, length)
          if read_length == 0
            raise "read_nonblock: read nothing"
          elsif LibC.errno == LibC::EWOULDBLOCK
            raise Errno.new "exception in read_nonblock"
          else
            {read_length.to_i, 0}
          end
        end
      ensure
        LibC.fcntl(fd, LibC::FCNTL::F_SETFL, before)
      end
    end
  end
end
