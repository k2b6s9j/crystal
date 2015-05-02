lib LibC
  ifdef darwin || linux
    fun system(str : UInt8*) : Int32
    fun execl(path : UInt8*, arg0 : UInt8*, ...) : Int32
    fun execvp(file : UInt8*, argv : UInt8**) : Int32
  elsif windows
    P_WAIT    = 0 # synchronous spawn (returns exit code)
    P_NOWAIT  = 1 # asynchronous spawn (return handle)
    P_OVERLAY = 2 # mimic exec
    P_NOWAITO = 3
    P_DETACH  = 4 # spawned process runs in background (no cwait)

    fun wsystem = _wsystem(str : UInt16*) : Int32
    fun wexecl = _wexecl(path : UInt16*, arg0 : UInt16*, ...) : Int32
    fun wexecvp = _wexecvp(file : UInt16*, argv : UInt16**) : IntT
    fun wspawnvp = _wspawnvp(mode : Int32, cmdname : UInt16*, argv : UInt16**) : IntT
  end
end

def Process.run(command, args = nil, output = nil : IO | Bool, input = nil : String | IO)
  ifdef darwin || linux
    argv = [command.cstr]
    if args
      args.each do |arg|
        argv << arg.cstr
      end
    end
    argv << Pointer(UInt8).null

    if output
      process_output, fork_output = IO.pipe
    end

    if input
      fork_input, process_input = IO.pipe
    end

    pid = fork do
      if output == false
        null = File.new("/dev/null", "r+")
        STDOUT.reopen null
        STDERR.reopen null
        null.close
      elsif fork_output
        STDOUT.reopen fork_output
        STDERR.reopen fork_output
        fork_output.close
      end

      if process_input && fork_input
        process_input.close
        STDIN.reopen fork_input
        fork_input.close
      end

      LibC.execvp(command, argv.buffer)
      LibC.exit 127
    end

    if pid == -1
      raise Errno.new("Error executing system command '#{command}'")
    end

    status = Process::Status.new(pid)

    if input
      process_input = process_input.not_nil!
      fork_input.not_nil!.close

      case input
      when String
        process_input.print input
        process_input.close
        process_input = nil
      when IO
        input_io = input
      end
    end

    if output
      fork_output.not_nil!.close

      case output
      when true
        status_output = StringIO.new
      when IO
        status_output = output
      end
    end

    while process_input || process_output
      wios = nil
      rios = nil

      if process_input
        wios = {process_input}
      end

      if process_output
        rios = {process_output}
      end

      buffer :: UInt8[2048]

      ios = IO.select(rios, wios)
      next unless ios

      if process_input && ios.includes? process_input
        bytes = input_io.not_nil!.read(buffer.to_slice)
        if bytes == 0
          process_input.close
          process_input = nil
        else
          process_input.write(buffer.to_slice, bytes)
        end
      end

      if process_output && ios.includes? process_output
        bytes = process_output.read(buffer.to_slice)
        if bytes == 0
          process_output.close
          process_output = nil
        else
          status_output.not_nil!.write(buffer.to_slice, bytes)
        end
      end
    end

    status.exit = Process.waitpid(pid)

    if output == true
      status.output = status_output.to_s
    end

    status
  elsif windows
    argv = [command.to_utf16]
    if args
      args.each do |arg|
        argv << arg.to_utf16
      end
    end
    argv << Pointer(UInt16).null

    if output
      read_from_child, child_output = IO.pipe
      outputio = child_output

      case output
      when true
        status_output = StringIO.new
      when IO
        status_output = output
      end
    elsif output == false
      null = File.new("NUL", "r+")
      outputio = null
    end

    if outputio
      stdout = STDOUT.dup
      stderr = STDERR.dup
      STDOUT.reopen outputio
      STDERR.reopen outputio
      outputio.close
    end

    if input.is_a?(String)
      child_input, write_to_child = IO.pipe
      stdin = STDIN.dup
      STDIN.reopen child_input
      child_input.close
    end

    proc = LibC.wspawnvp(LibC::P_NOWAIT, command.to_utf16, argv.buffer)

    if stdout && stderr
      STDOUT.reopen stdout
      STDERR.reopen stderr
      stdout.close
      stderr.close
    end

    if stdin
      STDIN.reopen stdin
      stdin.close
    end

    if proc == -1
      raise Errno.new("Error executing system command '#{command}'")
    end

    pid = LibWin32.getprocessid(proc)
    status = Process::Status.new(pid)

    if write_to_child
        write_to_child.print input
        write_to_child.close
    end

    exit_code :: UInt32
    if read_from_child
      loop do
        buf :: UInt8[2048]

        LibWin32.getexitcodeprocess(proc, pointerof(exit_code))
        peeked = LibWin32.peeknamedpipe(read_from_child.handle, nil, 0_u32, nil, out avail, nil)
        if peeked && avail > 0
          bytes = read_from_child.read(buf.to_slice)
          status_output.not_nil!.write(buf.to_slice, bytes) if bytes > 0
        elsif exit_code != LibWin32::STILL_ACTIVE
          read_from_child.close
          break
        end
      end
    else
      exit_code = Process.waitpid(pid).to_u32
    end

    status.exit = exit_code.to_i

    if output == true
      status.output = status_output.to_s
    end

    status
  end
end

def system(command : String)
  ifdef darwin || linux
    status = Process.run("/bin/sh", input: command, output: STDOUT)
  elsif windows
    status = Process.run("cmd.exe", {"/c", command}, STDOUT)
  end
  $? = status
  status.success?
end

def `(command)
  ifdef darwin || linux
    status = Process.run("/bin/sh", input: command, output: true)
  elsif windows
    status = Process.run("cmd.exe", {"/c", command}, true)
  end
  $? = status
  status.output.not_nil!
end
