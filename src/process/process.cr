lib LibC
  fun exit(status : Int32) : NoReturn

  ifdef darwin || linux
    @[ReturnsTwice]
    fun fork : Int32

    fun getpid : Int32
    fun getppid : Int32
    fun waitpid(pid : Int32, stat_loc : Int32*, options : Int32) : Int32

    ifdef x86_64
      ClockT = UInt64
    else
      ClockT = UInt32
    end

    SC_CLK_TCK = 3

    struct Tms
      utime : ClockT
      stime : ClockT
      cutime : ClockT
      cstime : ClockT
    end

    fun times(buffer : Tms*) : ClockT
    fun sysconf(name : Int32) : Int64

    fun sleep(seconds : UInt32) : UInt32
    fun usleep(useconds : UInt32) : UInt32
  elsif windows
    WAIT_CHILD      = 0
    WAIT_GRANDCHILD = 1

    fun getpid = _getpid : Int32
    fun cwait = _cwait(termstat : Int32*, proc : IntT, action : Int32) : IntT
  end
end

module Process
  def self.exit(status = 0)
    LibC.exit(status)
  end

  def self.pid
    LibC.getpid()
  end

  def self.ppid
    ifdef darwin || linux
      LibC.getppid()
    elsif windows
      snapshot = LibWin32.createtoolhelp32snapshot(LibWin32::TH32CS_SNAPPROCESS, 0_u32)

      unless snapshot
        raise WinError.new("Snapshot failed")
      end

      pe32 :: LibWin32::WPROCESSENTRY32
      pe32.dwsize = sizeof(typeof(pe32)).to_u32

      retval = 0_u32
      pid = self.pid

      if LibWin32.wprocess32first(snapshot, pointerof(pe32))
        loop do
          if pe32.th32processid == pid
            retval = pe32.th32parentprocessid
            break
          end
          break unless LibWin32.wprocess32next(snapshot, pointerof(pe32))
        end
      end
      LibWin32.closehandle snapshot
      retval
    end
  end

  def self.waitpid(pid)
    ifdef darwin || linux
      if LibC.waitpid(pid, out exit_code, 0) == -1
        raise Errno.new("Error during waitpid")
      end

      exit_code >> 8
    elsif windows
      if pid != -1
        proc = LibWin32.openprocess(LibWin32::SYNCHRONIZE | LibWin32::PROCESS_QUERY_INFORMATION, false, pid.to_u32)

        if proc == 0
          raise WinError.new("Process does not exist")
        end

        if LibC.cwait(out exit_code, proc, LibC::WAIT_CHILD) == -1
          raise Errno.new("Error during waitpid")
        end

        LibWin32.closehandle proc

        exit_code
      else
        snapshot = LibWin32.createtoolhelp32snapshot(LibWin32::TH32CS_SNAPPROCESS, 0_u32)

        unless snapshot
          raise WinError.new("Snapshot failed")
        end

        pe32 :: LibWin32::WPROCESSENTRY32
        pe32.dwsize = sizeof(typeof(pe32)).to_u32

        children = [] of LibC::IntT
        ppid = self.pid

        if LibWin32.wprocess32first(snapshot, pointerof(pe32))
          loop do
            if pe32.th32parentprocessid == ppid
              children << LibWin32.openprocess(LibWin32::SYNCHRONIZE | LibWin32::PROCESS_QUERY_INFORMATION, false, pe32.th32processid)
            end
            break unless LibWin32.wprocess32next(snapshot, pointerof(pe32))
          end
        end
        LibWin32.closehandle snapshot

        return 0 if children.empty?

        index = LibWin32.waitformultipleobjects(children.length.to_u32, children.buffer, false, LibWin32::INFINITE)
        if index == -1
          raise WinError.new("Error during WaitForMultipleObjects")
        end

        LibWin32.getexitcodeprocess(children[index], out exit_code_u)

        children.each { |child| LibWin32.closehandle(child) }

        exit_code_u.to_i
      end
    end
  end

  ifdef darwin || linux
    def self.fork(&block)
      pid = self.fork()

      unless pid
        yield
        exit
      end

      pid
    end

    def self.fork
      pid = LibC.fork
      pid = nil if pid == 0
      pid
    end

    record Tms, utime, stime, cutime, cstime

    def self.times
      hertz = LibC.sysconf(LibC::SC_CLK_TCK).to_f
      LibC.times(out tms)
      Tms.new(tms.utime / hertz, tms.stime / hertz, tms.cutime / hertz, tms.cstime / hertz)
    end
  end
end

ifdef darwin || linux
  def fork
    Process.fork { yield }
  end

  def fork()
    Process.fork()
  end
elsif windows
  # win32: TODO: remove it entirely and replace with threads/processes
  def fork
    yield
  end
end

require "./*"
