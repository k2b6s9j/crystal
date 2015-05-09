require "../abi"

# Based on https://github.com/rust-lang/rust/blob/master/src/librustc_trans/trans/cabi_arm.rs
class LLVM::ABI::ARM < LLVM::ABI
  def abi_info(atys: Array(Type), rty: Type, ret_def: Bool)
    ret_ty = compute_return_type(rty, ret_def)
    arg_tys = compute_arg_types(atys)
  end

  # For more information on iOS see:
  # ARMv7
  # https://developer.apple.com/library/ios/documentation/Xcode/Conceptual
  #    /iPhoneOSABIReference/Articles/ARMv7FunctionCallingConventions.html
  # ARMv6
  # https://developer.apple.com/library/ios/documentation/Xcode/Conceptual
  #    /iPhoneOSABIReference/Articles/ARMv6FunctionCallingConventions.html
  private def align(type: Type)
    case type.kind
    when Type::Kind::Integer
      if is_ios
        Math.min(4, ((type.int_width + 7) / 8))
      else
        (type.int_width + 7) / 8
      end
    when Type::Kind::Pointer
      4
    when Type::Kind::Float
      4
    when Type::Kind::Double
      if is_ios
        4
      else
        8
      end
    when Type::Kind::Struct
      if type.packed_struct?
        1
      else
        type.struct_element_types.inject(1) do |a, t|
          Math.max(a, align(t))
        end
      end
    when Type::Kind::Array then ios_align(type.element_type)
    #when Type::Kind::Vector then align(type.element_type) * type.vector_length
    else
      raise "Unhandled Type::Kind: #{type.kind}"
    end
  end

  private def reg_type?(type: Type)
    case type.kind
    when Type::Kind::Integer then true
    when Type::Kind::Pointer then true
    when Type::Kind::Float then true
    when Type::Kind::Double then true
    #when Type::Kind::Vector then true
    else
      false
    end
  end

  private def align_up_to(off, a)
    (off + a - 1) / a * a
  end

  private def align(off, ty: Type, align_fn)
    align_up_to(off, align_fn(ty))
  end

  private def type_size(type: Type, align_fn)
    case type.kind
    when Type::Kind::Integer then (type.int_width + 7) / 8
    when Type::Kind::Pointer then 4
    when Type::Kind::Float then 4
    when Type::Kind::Double then 8
    when Type::Kind::Struct
      if type.packed_struct?
        type.struct_element_types.each do |s, t|
          s + type_size(t, align_fn)
        end
      else
        type.struct_element_types.each do |s, t|
          align(s, t, align_fn) + type_size(t, align_fn)
        end
        align(size, type, align_fn)
      end
    when Type::Kind::Array
      length = type.array_length
      element = type.element_type
      type_size(element, align_fn) * len
    #when Type::Kind::Vector
    #  length = type.vector_length
    #  element = type.element_type
    #  type_size(element, align_fn) * len
    else
      raise "Unhandled Type::Kind: #{type.kind}"
    end
  end

  private def compute_return_type(rty, ret_def)
  end

  private def compute_arg_types(atys)
  end
end
