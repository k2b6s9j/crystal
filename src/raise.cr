ifdef darwin || linux
  lib LibABI
    struct UnwindException
      exception_class : LibC::SizeT
      exception_cleanup : LibC::SizeT
      private1 : UInt64
      private2 : UInt64
      exception_object : UInt64
      exception_type_id : Int32
    end

    UA_SEARCH_PHASE = 1
    UA_CLEANUP_PHASE = 2
    UA_HANDLER_FRAME = 4
    UA_FORCE_UNWIND = 8

    URC_NO_REASON = 0
    URC_FOREIGN_EXCEPTION_CAUGHT = 1
    URC_FATAL_PHASE2_ERROR = 2
    URC_FATAL_PHASE1_ERROR = 3
    URC_NORMAL_STOP = 4
    URC_END_OF_STACK = 5
    URC_HANDLER_FOUND = 6
    URC_INSTALL_CONTEXT = 7
    URC_CONTINUE_UNWIND = 8

    ifdef x86_64
      EH_REGISTER_0 = 0
      EH_REGISTER_1 = 1
    else
      EH_REGISTER_0 = 0
      EH_REGISTER_1 = 2
    end

    fun unwind_raise_exception = _Unwind_RaiseException(ex : UnwindException*) : Int32
    fun unwind_get_region_start = _Unwind_GetRegionStart(context : Void*) : LibC::SizeT
    fun unwind_get_ip = _Unwind_GetIP(context : Void*) : LibC::SizeT
    fun unwind_set_ip = _Unwind_SetIP(context : Void*, ip : LibC::SizeT) : LibC::SizeT
    fun unwind_set_gr = _Unwind_SetGR(context : Void*, index : Int32, value : LibC::SizeT)
    fun unwind_get_language_specific_data = _Unwind_GetLanguageSpecificData(context : Void*) : UInt8*
  end

  struct LEBReader
    def initialize(@data : UInt8*)
    end

    def data
      @data
    end

    def read_uint8
      value = @data.value
      @data += 1
      value
    end

    def read_uint32
      value = (@data as UInt32*).value
      @data += 4
      value
    end

    def read_uleb128
      result = 0_u64
      shift = 0
      while true
        byte = read_uint8
        result |= ((0x7f_u64 & byte) << shift);
        break if (byte & 0x80_u8) == 0
        shift += 7
      end
      result
    end
  end

  fun __crystal_personality(version : Int32, actions : Int32, exception_class : UInt64, exception_object : LibABI::UnwindException*, context : Void*) : Int32
    start = LibABI.unwind_get_region_start(context)
    ip = LibABI.unwind_get_ip(context)
    throw_offset = ip - 1 - start
    lsd = LibABI.unwind_get_language_specific_data(context)
    # puts "Personality - actions : #{actions}, start: #{start}, ip: #{ip}, throw_offset: #{throw_offset}"

    leb = LEBReader.new(lsd)
    leb.read_uint8 # @LPStart encoding
    if leb.read_uint8 != 0xff_u8 # @TType encoding
      leb.read_uleb128 # @TType base offset
    end
    leb.read_uint8 # CS Encoding
    cs_table_length = leb.read_uleb128 # CS table length
    cs_table_end = leb.data + cs_table_length

    while leb.data < cs_table_end
      cs_offset = leb.read_uint32
      cs_length = leb.read_uint32
      cs_addr = leb.read_uint32
      action = leb.read_uleb128
      # puts "cs_offset: #{cs_offset}, cs_length: #{cs_length}, cs_addr: #{cs_addr}, action: #{action}"

      if cs_addr != 0
        if cs_offset <= throw_offset && throw_offset <= cs_offset + cs_length
          if (actions & LibABI::UA_SEARCH_PHASE) > 0
            # puts "found"
            return LibABI::URC_HANDLER_FOUND
          end

          if (actions & LibABI::UA_HANDLER_FRAME) > 0
            LibABI.unwind_set_gr(context, LibABI::EH_REGISTER_0, LibC::SizeT.cast(exception_object.address))
            LibABI.unwind_set_gr(context, LibABI::EH_REGISTER_1, LibC::SizeT.cast(exception_object.value.exception_type_id))
            LibABI.unwind_set_ip(context, start + cs_addr)
            # puts "install"
            return LibABI::URC_INSTALL_CONTEXT
          end
        end
      end
    end

    # puts "continue"
    return LibABI::URC_CONTINUE_UNWIND
  end

  @[Raises]
  fun __crystal_raise(unwind_ex : LibABI::UnwindException*) : NoReturn
    ret = LibABI.unwind_raise_exception(unwind_ex)
    LibC.printf "Could not raise"
    # caller.each do |point|
      # puts point
    # end
    LibC.exit(ret)
  end

  fun __crystal_get_exception(unwind_ex : LibABI::UnwindException*) : UInt64
    unwind_ex.value.exception_object
  end

  def raise(ex : Exception)
    unwind_ex = Pointer(LibABI::UnwindException).malloc
    unwind_ex.value.exception_class = LibC::SizeT.zero
    unwind_ex.value.exception_cleanup = LibC::SizeT.zero
    unwind_ex.value.exception_object = ex.object_id
    unwind_ex.value.exception_type_id = ex.crystal_type_id
    __crystal_raise(unwind_ex)
  end

  def raise(message : String)
    raise Exception.new(message)
  end

  fun __crystal_raise_string(message : UInt8*)
    raise String.new(message)
  end
elsif windows
  fun __crystal_personality(version : Int32, actions : Int32, exception_class : UInt64, exception_object : Void*, context : Void*) : Int32
    # puts "continue"
    return 8
  end

  @[Raises]
  fun __crystal_raise(unwind_ex : Void*) : NoReturn
    LibC.printf "Could not raise"
    LibC.exit 1
  end

  fun __crystal_get_exception(unwind_ex : Void*) : UInt64
    0_u64
  end

  def raise(ex : Exception)
    if msg = ex.message
      LibC.printf msg
    end

    LibC.exit 1
  end

  def raise(message : String)
    raise Exception.new(message)
  end
end
