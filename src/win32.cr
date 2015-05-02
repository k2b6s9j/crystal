@[Link("ws2_32")]
lib LibWin32
  @[CallConvention("X86_StdCall")]
  fun getlasterror = GetLastError : UInt32

  @[CallConvention("X86_StdCall")]
  fun closehandle = CloseHandle(handle : LibC::IntT) : Bool

  INFINITE = 0xFFFFFFFF_u32

  @[CallConvention("X86_StdCall")]
  fun waitforsingleobject = WaitForSingleObject(handle : LibC::IntT, ms : UInt32) : UInt32

  @[CallConvention("X86_StdCall")]
  fun waitformultipleobjects = WaitForMultipleObjects(count : UInt32, handles : LibC::IntT*, wait_for_all : Bool, ms : UInt32) : UInt32

  @[CallConvention("X86_StdCall")]
  fun sleep = Sleep(seconds : UInt32) : UInt32

  @[CallConvention("X86_StdCall")]
  fun multibytetowidechar = MultiByteToWideChar(code_page : UInt32, flags : UInt32, str : UInt8*, len : Int32, buf : UInt16*, size : Int32) : Int32
  @[CallConvention("X86_StdCall")]
  fun widechartomultibyte = WideCharToMultiByte(code_page : UInt32, flags : UInt32, str : UInt16*, len : Int32, buf : UInt8*, size : Int32, def_char : UInt8*, used_char : Bool*) : Int32

  FOREGROUND_BLUE      = 0x1_u16
  FOREGROUND_GREEN     = 0x2_u16
  FOREGROUND_RED       = 0x4_u16
  FOREGROUND_INTENSITY = 0x8_u16
  BACKGROUND_BLUE      = 0x10_u16
  BACKGROUND_GREEN     = 0x20_u16
  BACKGROUND_RED       = 0x40_u16
  BACKGROUND_INTENSITY = 0x80_u16

  FOREGROUND_MASK = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE | FOREGROUND_INTENSITY
  BACKGROUND_MASK = BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE | BACKGROUND_INTENSITY

  @[CallConvention("X86_StdCall")]
  fun setconsoletextattribute = SetConsoleTextAttribute(console : LibC::IntT, attr : UInt16) : Bool

  struct Coord
    x : Int16
    y : Int16
  end

  struct SmallRect
    left : Int16
    top : Int16
    right : Int16
    bottom : Int16
  end

  struct ConsoleScreenBufferInfo
    size : Coord
    pos : Coord
    attr : UInt16
    window : SmallRect
    max_size : Coord
  end

  @[CallConvention("X86_StdCall")]
  fun getconsolescreenbufferinfo = GetConsoleScreenBufferInfo(console : LibC::IntT, info : ConsoleScreenBufferInfo*) : Bool

  FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200_u32
  FORMAT_MESSAGE_FROM_STRING    = 0x00000400_u32
  FORMAT_MESSAGE_FROM_HMODULE   = 0x00000800_u32
  FORMAT_MESSAGE_FROM_SYSTEM    = 0x00001000_u32
  FORMAT_MESSAGE_ARGUMENT_ARRAY = 0x00002000_u32
  FORMAT_MESSAGE_MAX_WIDTH_MASK = 0x000000ff_u32

  LANG_NEUTRAL    = 0x00_u32
  SUBLANG_DEFAULT = 0x01_u32

  @[CallConvention("X86_StdCall")]
  fun wformatmessage = FormatMessageW(flags : UInt32, src : Void*, messageid : UInt32, languageid : UInt32, buf : UInt16*, size : UInt32, args : Void*) : UInt32

  @[CallConvention("X86_StdCall")]
  fun wgetcommandline = GetCommandLineW : UInt16*

  @[CallConvention("X86_StdCall")]
  fun wcommandlinetoargv = CommandLineToArgvW(cmdline : UInt16*, argc : UInt32*) : UInt16**

  @[CallConvention("X86_StdCall")]
  fun wgetmodulefilename = GetModuleFileNameW(module : LibC::IntT, filename : UInt16*, size : UInt32) : UInt32

  @[CallConvention("X86_StdCall")]
  fun peeknamedpipe = PeekNamedPipe(pipe : LibC::IntT, buf : Void*, cb : UInt32, read : UInt32*, avail : UInt32*, left : UInt32*) : Bool

  @[CallConvention("X86_StdCall")]
  fun openprocess = OpenProcess(access : UInt32, inherit : Bool, pid : UInt32) : LibC::IntT

  SYNCHRONIZE              = 0x00100000_u32 # Required to wait for the process to terminate
  STANDARD_RIGHTS_REQUIRED = 0x000F0000_u32
  GENERIC_READ             = 0x80000000_u32
  GENERIC_WRITE            = 0x40000000_u32
  GENERIC_EXECUTE          = 0x20000000_u32
  GENERIC_ALL              = 0x10000000_u32

  PROCESS_TERMINATE                 = 0x0001_u32 # Required to terminate a process using TerminateProcess
  PROCESS_CREATE_THREAD             = 0x0002_u32 # Required to create a thread
  PROCESS_SET_SESSIONID             = 0x0004_u32
  PROCESS_VM_OPERATION              = 0x0008_u32 # Required to perform an operation on the address space of a process
  PROCESS_VM_READ                   = 0x0010_u32 # Required to read memory in a process using ReadProcessMemory
  PROCESS_VM_WRITE                  = 0x0020_u32 # Required to write to memory in a process using WriteProcessMemory
  PROCESS_DUP_HANDLE                = 0x0040_u32 # Required to duplicate a handle using DuplicateHandle
  PROCESS_CREATE_PROCESS            = 0x0080_u32 # Required to create a process
  PROCESS_SET_QUOTA                 = 0x0100_u32 # Required to set memory limits using SetProcessWorkingSetSize
  PROCESS_SET_INFORMATION           = 0x0200_u32 # Required to set certain information about a process
  PROCESS_QUERY_INFORMATION         = 0x0400_u32 # Required to retrieve certain information about a process (token, exit code, priority class)
  PROCESS_SUSPEND_RESUME            = 0x0800_u32 # Required to suspend or resume a process
  PROCESS_QUERY_LIMITED_INFORMATION = 0x1000_u32 # Required to retrieve certain information about a process
  PROCESS_ALL_ACCESS                = STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0xffff

  @[CallConvention("X86_StdCall")]
  fun openthread = OpenThread(access : UInt32, inherit : Bool, tid : UInt32) : LibC::IntT

  THREAD_TERMINATE                 = 0x0001_u32
  THREAD_SUSPEND_RESUME            = 0x0002_u32
  THREAD_GET_CONTEXT               = 0x0008_u32
  THREAD_SET_CONTEXT               = 0x0010_u32
  THREAD_SET_INFORMATION           = 0x0020_u32
  THREAD_QUERY_INFORMATION         = 0x0040_u32
  THREAD_SET_THREAD_TOKEN          = 0x0080_u32
  THREAD_IMPERSONATE               = 0x0100_u32
  THREAD_DIRECT_IMPERSONATION      = 0x0200_u32
  THREAD_SET_LIMITED_INFORMATION   = 0x0400_u32
  THREAD_QUERY_LIMITED_INFORMATION = 0x0800_u32
  THREAD_ALL_ACCESS                = STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0xffff_u32

  @[CallConvention("X86_StdCall")]
  fun getexitcodeprocess = GetExitCodeProcess(proc : LibC::IntT, code : UInt32*) : Bool

  STILL_ACTIVE = 0x103

  @[CallConvention("X86_StdCall")]
  fun getprocessid = GetProcessId(proc : LibC::IntT) : UInt32

  MAX_MODULE_NAME32 = 255

  @[CallConvention("X86_StdCall")]
  fun createtoolhelp32snapshot = CreateToolhelp32Snapshot(flags : UInt32, pid : UInt32) : LibC::IntT

  TH32CS_SNAPHEAPLIST = 0x00000001_u32
  TH32CS_SNAPPROCESS  = 0x00000002_u32
  TH32CS_SNAPTHREAD   = 0x00000004_u32
  TH32CS_SNAPMODULE   = 0x00000008_u32
  TH32CS_SNAPMODULE32 = 0x00000010_u32
  TH32CS_SNAPALL      = TH32CS_SNAPHEAPLIST | TH32CS_SNAPPROCESS | TH32CS_SNAPTHREAD | TH32CS_SNAPMODULE
  TH32CS_INHERIT      = 0x80000000_u32

  struct HEAPLIST32
    size : LibC::SizeT
    pid : UInt32
    hid : LibC::UIntT
    flags : UInt32
  end

  HF32_DEFAULT = 1
  HF32_SHARED  = 2

  @[CallConvention("X86_StdCall")]
  fun heap32listfirst = Heap32ListFirst(snapshot : LibC::IntT, hl : HEAPLIST32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun heap32listnext = Heap32ListNext(snapshot : LibC::IntT, hl : HEAPLIST32*) : Bool

  struct HEAPENTRY32
    size : LibC::SizeT
    handle : LibC::IntT
    addr : LibC::UIntT
    block_size : LibC::SizeT
    flags : UInt32
    lock_count : UInt32
    reserved : UInt32
    pid : UInt32
    hid : LibC::UIntT
  end

  LF32_FIXED    = 0x00000001_u32
  LF32_FREE     = 0x00000002_u32
  LF32_MOVEABLE = 0x00000004_u32

  @[CallConvention("X86_StdCall")]
  fun heap32first = Heap32First(he : HEAPENTRY32*, pid : UInt32, hid : LibC::UIntT) : Bool
  @[CallConvention("X86_StdCall")]
  fun heap32next = Heap32Next(he : HEAPENTRY32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun toolhelp32readprocessmemory = Toolhelp32ReadProcessMemory(pid : UInt32, addr : Void*, buf : Void*, cb : LibC::SizeT, read : LibC::SizeT*) : Bool

  struct WPROCESSENTRY32
    size : UInt32
    usage : UInt32
    pid : UInt32
    def_hid : LibC::UIntT
    mid : UInt32
    threads : UInt32
    ppid : UInt32
    priority : UInt32
    flags : UInt32
    filename : UInt16[LibC::MAX_PATH]
  end

  @[CallConvention("X86_StdCall")]
  fun wprocess32first = Process32FirstW(snapshot : LibC::IntT, pe : WPROCESSENTRY32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun wprocess32next = Process32NextW(snapshot : LibC::IntT, pe : WPROCESSENTRY32*) : Bool

  struct THREADENTRY32
    size : UInt32
    usage : UInt32
    tid : UInt32
    pid : LibC::UIntT
    priority : UInt32
    priority_delta : UInt32
    flags : UInt32
  end

  @[CallConvention("X86_StdCall")]
  fun thread32first = Thread32First(snapshot : LibC::IntT, te : THREADENTRY32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun thread32next = Thread32Next(snapshot : LibC::IntT, te : THREADENTRY32*) : Bool

  struct WMODULEENTRY32
    size : UInt32
    mid : UInt32
    pid : UInt32
    proc_usage : UInt32
    global_usage : UInt32
    mod_addr : UInt8*
    mod_size : UInt8*
    mod : LibC::IntT
    name : UInt16[MAX_MODULE_NAME32]
    filename : UInt16[LibC::MAX_PATH]
  end

  @[CallConvention("X86_StdCall")]
  fun wmodule32first = Module32FirstW(snapshot : LibC::IntT, me : WMODULEENTRY32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun wmodule32next = Module32NextW(snapshot : LibC::IntT, me : WMODULEENTRY32*) : Bool

  WSADESCRIPTION_LEN = 256
  WSASYS_STATUS_LEN  = 128

  struct WSADATA
    version : UInt16
    hversion : UInt16
    description : UInt8[WSADESCRIPTION_LEN]
    status : UInt8[WSASYS_STATUS_LEN]
    max_sockets : UInt16
    max_udpdg : UInt16
    vendor_info : UInt8*
  end

  @[CallConvention("X86_StdCall")]
  fun wsastartup = WSAStartup(version : UInt16, wsadata : WSADATA*) : Int32
end

LibWin32.wsastartup(0x0202_u16, out wsadata)
