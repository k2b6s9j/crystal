lib LibC
  ifdef darwin || windows
    alias ModeT = UInt16
  elsif linux
    alias ModeT = UInt32
  end

  ifdef x86_64
    alias IntT = Int64
    alias UIntT = UInt64
    alias LongT = Int64
  else
    alias IntT = Int32
    alias UIntT = UInt32
    alias LongT = Int32
  end

  alias PtrDiffT = IntT
  alias SizeT = UIntT
  alias SSizeT = IntT
  alias TimeT = IntT

  ifdef windows
    MAX_PATH = 260
  end

  fun malloc(size : UInt32) : Void*
  fun realloc(ptr : Void*, size : UInt32) : Void*
  fun free(ptr : Void*)
  fun time(t : Int64*) : Int64
  fun free(ptr : Void*)
  fun memcmp(p1 : Void*, p2 : Void*, size : LibC::SizeT) : Int32
end
