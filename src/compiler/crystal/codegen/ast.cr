require "../syntax/ast"

module Crystal
  class ASTNode
    def returns?
      false
    end

    def yields?
      false
    end

    def breaks?
      false
    end

    def nexts?
      false
    end

    def no_returns?
      type?.try &.no_return?
    end

    def zero?
      false
    end

    def false?
      false
    end
  end

  class BoolLiteral
    def false?
      !value
    end
  end

  class NumberLiteral
    def zero?
      case :kind
      when :f32, :f64
        value == "0.0"
      else
        value == "0"
      end
    end
  end

  class Assign
    def returns?
      value.returns?
    end

    def yields?
      value.yields?
    end

    def breaks?
      value.breaks?
    end

    def nexts?
      value.breaks?
    end
  end

  class Return
    def returns?
      true
    end
  end

  class Yield
    def yields?
      true
    end
  end

  class Break
    def breaks?
      true
    end
  end

  class Next
    def nexts?
      true
    end
  end

  class Expressions
    def returns?
      expressions.any? &.returns?
    end

    def yields?
      expressions.any? &.yields?
    end

    def breaks?
      expressions.any? &.breaks?
    end

    def nexts?
      expressions.any? &.breaks?
    end
  end

  class Block
    def returns?
      body.returns?
    end

    def breaks?
      body.breaks?
    end

    def yields?
      body.yields?
    end

    def nexts?
      body.nexts?
    end
  end

  class If
    def returns?
      self.then.returns? && self.else.returns?
    end

    def yields?
      self.then.yields? && self.else.yields?
    end

    def breaks?
      self.then.breaks? && self.else.breaks?
    end

    def nexts?
      self.then.nexts? && self.else.nexts?
    end
  end

  class Call
    def returns?
      block = @block
      block && block.returns? && target_defs.try &.all? &.body.yields?
    end

    def yields?
      return true if args.any?(&.yields?)

      if block.try &.yields?
        target_defs.try &.any? &.body.yields?
      end
    end
  end

  class Def
    def mangled_name(self_type)
      name = String.build do |str|
        str << "*"

        if owner = @owner
          if owner.metaclass?
            owner.instance_type.llvm_name(str)
            str << "::"
          elsif !owner.is_a?(Crystal::Program)
            owner.llvm_name(str)
            if original_owner != self_type
              str << "@"
              original_owner.llvm_name(str)
            end
            str << "#"
          end
        end

        str << name.gsub('@', '.')

        next_def = self.next
        while next_def
          str << "'"
          next_def = next_def.next
        end

        needs_self_type = self_type.try &.passed_as_self?

        if args.length > 0 || needs_self_type || uses_block_arg
          str << "<"
          if needs_self_type
            self_type.not_nil!.llvm_name(str)
          end
          if args.length > 0
            str << ", " if needs_self_type
            args.each_with_index do |arg, i|
              str << ", " if i > 0
              arg.type.llvm_name(str)
            end
          end
          if uses_block_arg
            str << ", " if needs_self_type || args.length > 0
            str << "&"
            block_arg.not_nil!.type.llvm_name(str)
          end
          str << ">"
        end
        if return_type = @type
          str << ":"
          return_type.llvm_name(str)
        end
      end

      # win32: what is this actually for?
      # 1. it's flawed because it makes identifiers ambiguous
      # 2. it doesn't seem to be necessary when using MinGW
      # 3. shouldn't it rather check whether it's _compiling_
      #    instead of _compiled_ for windows?
      # Windows only allows alphanumeric, dot, dollar and underscore
      # for mangled names.
      #ifdef windows
      #  name = name.gsub do |char|
      #    case char
      #    when '<', '>', '(', ')', '*', ':', ',', '#', ' '
      #      "."
      #    when '+'
      #      ".."
      #    else
      #      char
      #    end
      #  end
      #end

      name
    end

    def varargs
      false
    end
  end

  class External
    property abi_info
  end
end
