lib LibC
  ifdef darwin || linux
    fun access(filename : UInt8*, how : Int32) : Int32
    fun realpath(path : UInt8*, resolved_path : UInt8*) : UInt8*
    fun unlink(filename : UInt8*) : Int32
    fun rename(oldname : UInt8*, newname : UInt8*) : Int32
  elsif windows
    fun waccess = _waccess(filename : UInt16*, how : Int32) : Int32
    fun wfullpath = _wfullpath(buf : UInt16*, path : UInt16*, size : SizeT) : UInt16*
    fun wunlink = _wunlink(filename : UInt16*) : Int32
    fun wrename = _wrename(oldname : UInt16*, newname : UInt16*) : Int32
    fun get_osfhandle = _get_osfhandle(fd : Int32) : IntT
  end

  SEEK_SET = 0
  SEEK_CUR = 1
  SEEK_END = 2

  F_OK = 0
  X_OK = 1 << 0
  W_OK = 1 << 1
  R_OK = 1 << 2
end
