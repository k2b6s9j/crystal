# WINTYPE => CrystalType examples:
# DWORD => UInt32
# DWORD_PTR => UIntT
# HANDLE => IntT
# PVOID => Void*
# ULONG => UInt32
# ULONG_PTR => UIntT

@[Link("ws2_32")]
lib LibWin32

  ## winnt.h ##

  DELETE                   = 0x00010000_u32
  READ_CONTROL             = 0x00020000_u32
  WRITE_DAC                = 0x00040000_u32
  WRITE_OWNER              = 0x00080000_u32
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

  ## minwinbase.h ##

  STILL_ACTIVE = 0x103

  ## winbase.h ##

  IGNORE   = 0
  INFINITE = 0xFFFFFFFF_u32

  @[CallConvention("X86_StdCall")]
  fun waitformultipleobjects = WaitForMultipleObjects(count : UInt32, handles : LibC::IntT*, wait_for_all : Bool, ms : UInt32) : UInt32

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

  ## errhandlingapi.h ##

  @[CallConvention("X86_StdCall")]
  fun raiseexception = RaiseException(code : UInt32, flags : UInt32, argc : UInt32, argv : LibC::UIntT*)

  @[CallConvention("X86_StdCall")]
  fun getlasterror = GetLastError : UInt32

  ## handleapi.h ##

  INVALID_HANDLE_VALUE = LibC::IntT.cast(-1)

  @[CallConvention("X86_StdCall")]
  fun closehandle = CloseHandle(handle : LibC::IntT) : Bool

  @[CallConvention("X86_StdCall")]
  fun duplicatehandle = DuplicateHandle(source_proc : LibC::IntT, source_handle : LibC::IntT, target_proc : LibC::IntT, target_handle : LibC::IntT, access : UInt32, inherit : Bool, options : UInt32) : Bool

  @[CallConvention("X86_StdCall")]
  fun gethandleinformation = GetHandleInformation(obj : LibC::IntT, flags : UInt32*) : Bool

  @[CallConvention("X86_StdCall")]
  fun sethandleinformation = SetHandleInformation(obj : LibC::IntT, mask : UInt32, flags : UInt32) : Bool

  ## synchapi.h ##

  @[CallConvention("X86_StdCall")]
  fun waitforsingleobject = WaitForSingleObject(handle : LibC::IntT, ms : UInt32) : UInt32

  @[CallConvention("X86_StdCall")]
  fun sleep = Sleep(seconds : UInt32) : Void

  ## stringapiset.h ##

  @[CallConvention("X86_StdCall")]
  fun multibytetowidechar = MultiByteToWideChar(code_page : UInt32, flags : UInt32, str : UInt8*, len : Int32, buf : UInt16*, size : Int32) : Int32

  @[CallConvention("X86_StdCall")]
  fun widechartomultibyte = WideCharToMultiByte(code_page : UInt32, flags : UInt32, str : UInt16*, len : Int32, buf : UInt8*, size : Int32, defchar : UInt8*, used_defchar : Bool*) : Int32

  ## wincon.h ##

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

  FOREGROUND_BLUE            = 0x1_u16
  FOREGROUND_GREEN           = 0x2_u16
  FOREGROUND_RED             = 0x4_u16
  FOREGROUND_INTENSITY       = 0x8_u16
  BACKGROUND_BLUE            = 0x10_u16
  BACKGROUND_GREEN           = 0x20_u16
  BACKGROUND_RED             = 0x40_u16
  BACKGROUND_INTENSITY       = 0x80_u16
  FOREGROUND_MASK            = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE | FOREGROUND_INTENSITY
  BACKGROUND_MASK            = BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE | BACKGROUND_INTENSITY
  COMMON_LVB_LEADING_BYTE    = 0x100_u16
  COMMON_LVB_TRAILING_BYTE   = 0x200_u16
  COMMON_LVB_GRID_HORIZONTAL = 0x400_u16
  COMMON_LVB_GRID_LVERTICAL  = 0x800_u16
  COMMON_LVB_GRID_RVERTICAL  = 0x1000_u16
  COMMON_LVB_REVERSE_VIDEO   = 0x4000_u16
  COMMON_LVB_UNDERSCORE      = 0x8000_u16
  COMMON_LVB_SBCSDBCS        = 0x300_u16

  struct ConsoleScreenBufferInfo
    dwsize : Coord
    dwcursorposition : Coord
    wattributes : UInt16
    srwindow : SmallRect
    dwmaximumwindowsize : Coord
  end

  struct ConsoleCursorInfo
    dwsize : UInt32
    bvisible : Bool
  end

  struct ConsoleFontInfo
    nfont : UInt32
    dwfontsize : Coord
  end

  struct ConsoleSelectionInfo
    dwflags : UInt32
    dwselectionanchor : Coord
    srselection : SmallRect
  end

  @[CallConvention("X86_StdCall")]
  fun getconsolescreenbufferinfo = GetConsoleScreenBufferInfo(console : LibC::IntT, info : ConsoleScreenBufferInfo*) : Bool

  @[CallConvention("X86_StdCall")]
  fun setconsoletextattribute = SetConsoleTextAttribute(console : LibC::IntT, attr : UInt16) : Bool

  ## processenv.h ##

  @[CallConvention("X86_StdCall")]
  fun wgetcommandline = GetCommandLineW : UInt16*

  ## shellapi.h ##

  @[CallConvention("X86_StdCall")]
  fun wcommandlinetoargv = CommandLineToArgvW(cmdline : UInt16*, argc : UInt32*) : UInt16**

  ## libloaderapi.h ##

  @[CallConvention("X86_StdCall")]
  fun wgetmodulefilename = GetModuleFileNameW(module : LibC::IntT, filename : UInt16*, size : UInt32) : UInt32

  @[CallConvention("X86_StdCall")]
  fun wgetmodulehandle = GetModuleHandleW(modulename : UInt16*) : LibC::IntT

  @[CallConvention("X86_StdCall")]
  fun disablethreadlibrarycalls = DisableThreadLibraryCalls(module : LibC::IntT) : Bool

  @[CallConvention("X86_StdCall")]
  fun freelibrary = FreeLibrary(module : LibC::IntT) : Bool

  @[CallConvention("X86_StdCall")]
  fun getprocaddress = GetProcAddress(module : LibC::IntT, procname : UInt8*) : Void*

  ## namedpipeapi.h ##

  @[CallConvention("X86_StdCall")]
  fun peeknamedpipe = PeekNamedPipe(pipe : LibC::IntT, buf : Void*, cb : UInt32, read : UInt32*, avail : UInt32*, left : UInt32*) : Bool

  ## processthreadsapi.h ##

  @[CallConvention("X86_StdCall")]
  fun getexitcodeprocess = GetExitCodeProcess(proc : LibC::IntT, code : UInt32*) : Bool

  @[CallConvention("X86_StdCall")]
  fun openthread = OpenThread(access : UInt32, inherit : Bool, tid : UInt32) : LibC::IntT

  @[CallConvention("X86_StdCall")]
  fun getprocessid = GetProcessId(proc : LibC::IntT) : UInt32

  @[CallConvention("X86_StdCall")]
  fun openprocess = OpenProcess(access : UInt32, inherit : Bool, pid : UInt32) : LibC::IntT

  ## tlhelp32.h ##

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
    dwsize : LibC::SizeT
    th32processid : UInt32
    th32heapid : LibC::UIntT
    dwflags : UInt32
  end

  HF32_DEFAULT = 1
  HF32_SHARED  = 2

  @[CallConvention("X86_StdCall")]
  fun heap32listfirst = Heap32ListFirst(snapshot : LibC::IntT, hl : HEAPLIST32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun heap32listnext = Heap32ListNext(snapshot : LibC::IntT, hl : HEAPLIST32*) : Bool

  struct HEAPENTRY32
    dwsize : LibC::SizeT
    hhandle : LibC::IntT
    dwaddress : LibC::UIntT
    dwblocksize : LibC::SizeT
    dwflags : UInt32
    dwlockcount : UInt32
    dwresvd : UInt32
    th32processid : UInt32
    th32heapid : LibC::UIntT
  end

  LF32_FIXED    = 0x00000001_u32
  LF32_FREE     = 0x00000002_u32
  LF32_MOVEABLE = 0x00000004_u32

  @[CallConvention("X86_StdCall")]
  fun heap32first = Heap32First(he : HEAPENTRY32*, pid : UInt32, hid : LibC::UIntT) : Bool
  @[CallConvention("X86_StdCall")]
  fun heap32next = Heap32Next(he : HEAPENTRY32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun toolhelp32readprocessmemory = Toolhelp32ReadProcessMemory(pid : UInt32, addr : Void*, buf : Void*, size : LibC::SizeT, read : LibC::SizeT*) : Bool

  struct WPROCESSENTRY32
    dwsize : UInt32
    cntusage : UInt32
    th32processid : UInt32
    th32defaultheapid : LibC::UIntT
    th32moduleid : UInt32
    cntthreads : UInt32
    th32parentprocessid : UInt32
    pcpriclassbase : UInt32
    dwflags : UInt32
    szexefile : UInt16[LibC::MAX_PATH]
  end

  @[CallConvention("X86_StdCall")]
  fun wprocess32first = Process32FirstW(snapshot : LibC::IntT, pe : WPROCESSENTRY32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun wprocess32next = Process32NextW(snapshot : LibC::IntT, pe : WPROCESSENTRY32*) : Bool

  struct PROCESSENTRY32
    dwsize : UInt32
    cntusage : UInt32
    th32processid : UInt32
    th32defaultheapid : LibC::UIntT
    th32moduleid : UInt32
    cntthreads : UInt32
    th32parentprocessid : UInt32
    pcpriclassbase : UInt32
    dwflags : UInt32
    szexefile : UInt8[LibC::MAX_PATH]
  end

  @[CallConvention("X86_StdCall")]
  fun process32first = Process32First(snapshot : LibC::IntT, pe : PROCESSENTRY32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun process32next = Process32Next(snapshot : LibC::IntT, pe : PROCESSENTRY32*) : Bool

  struct THREADENTRY32
    dwsize : UInt32
    cntusage : UInt32
    th32threadid : UInt32
    th32ownerprocessid : LibC::UIntT
    tpbasepri : Int32
    tpdeltapri : Int32
    dwflags : UInt32
  end

  @[CallConvention("X86_StdCall")]
  fun thread32first = Thread32First(snapshot : LibC::IntT, te : THREADENTRY32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun thread32next = Thread32Next(snapshot : LibC::IntT, te : THREADENTRY32*) : Bool

  struct WMODULEENTRY32
    dwsize : UInt32
    th32moduleid : UInt32
    th32processid : UInt32
    glblcntusage : UInt32
    proccntusage : UInt32
    modbaseaddr : UInt8*
    modbasesize : UInt32
    hmodule : LibC::IntT
    #szmodule : UInt16[MAX_MODULE_NAME32 + 1] # TODO: Fix
    szmodule : UInt16[MAX_MODULE_NAME32]
    szexepath : UInt16[LibC::MAX_PATH]
  end

  @[CallConvention("X86_StdCall")]
  fun wmodule32first = Module32FirstW(snapshot : LibC::IntT, me : WMODULEENTRY32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun wmodule32next = Module32NextW(snapshot : LibC::IntT, me : WMODULEENTRY32*) : Bool

  struct MODULEENTRY32
    dwsize : UInt32
    th32moduleid : UInt32
    th32processid : UInt32
    glblcntusage : UInt32
    proccntusage : UInt32
    modbaseaddr : UInt8*
    modbasesize : UInt32
    hmodule : LibC::IntT
    #szmodule : UInt8[MAX_MODULE_NAME32 + 1] # TODO: Fix
    szmodule : UInt8[MAX_MODULE_NAME32]
    szexepath : UInt8[LibC::MAX_PATH]
  end

  @[CallConvention("X86_StdCall")]
  fun module32first = Module32First(snapshot : LibC::IntT, me : MODULEENTRY32*) : Bool
  @[CallConvention("X86_StdCall")]
  fun module32next = Module32Next(snapshot : LibC::IntT, me : MODULEENTRY32*) : Bool

  ## winsock2.h ##

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
