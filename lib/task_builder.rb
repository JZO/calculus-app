require 'Task'

class TaskBuilder < Array

  def push *args
    validate_tokens *args
    super
  end

  def task
    return Task.new(self) if validate_syntax
  end

  def ok?
    return validate_syntax
  end

  def self.operators
    return @@operators
  end

  def max_operand_index
    return each_with_index.max_by {|e,i| e.kind_of?(Fixnum) ? e.abs : 0 }.last
  end

  def copy
    return TaskBuilder.new(self)
  end

  def expand_operand operand_index, operator, op1, op2
    validate_tokens(operator,op1,op2)
    if self.size == 1
      self[0] = op1
      self[1] = operator
      self[2] = op2
      validate_syntax
      return self
    end
    validate_syntax
    TaskSyntaxError.new('Invalid operand index') if operand_index > self.size - 1
    assigned_operator = nil
    if operand_index < 2
      assigned_operator = self[operand_index + 1]
    elsif operand_index > self.size - 2
      assigned_operator = self[operand_index - 1]
    else
      left_token = self[operand_index - 1]
      right_token = self[operand_index + 1]
      # puts 'expading tokens :' + left_token +' ' + right_token
      operator_priority(right_token) > operator_priority(left_token)? assigned_operator = right_token : assigned_operator = left_token
    end
    if operator_priority(operator) < operator_priority(assigned_operator)
      self[operand_index,1] = ['(',op1,operator,op2,')']
    else
     self[operand_index,1] = [op1,operator,op2]
    end
    self
  end

  def last_operator
    idx = self.rindex { |token|
      @@operators.include?(token)
    }
    idx == nil ? nil : self[idx]
  end
#select priority operator  - left or right operator
  #  + op +  (left)
  #  - op -  (left)
  #  * op +  (left)
  #  + op *  (right)
  #  ( op +  (right)
  #  + op )  (left)
  #  ( op *  (right)
  #  * op )  (left)

  # priority operator rules
  # opposite to bracket -> */ left -> */ right -> left
  #

  # operand expansion rules
  # new_operator < assigned_operator -> insert brackets ->insert expansion
  # else
  # insert expansion
  #

  private
  def operator_priority operator
    case operator
    when '(', ')'
      return -1
    when :+,:-
      return 0
    when :*, :/
      return 1
    end
  end

  def validate_syntax
    raise TaskSyntaxError.new(self) if length == 0 or not(literal?(self[0]) or bracket_start?(self[0]))
    validate_syntax_p(0)
    return true
  end

  def validate_syntax_p offset
    position = offset
    previous_type = nil
    t_type = token_type(self[offset])
    raise TaskSyntaxError.new(self) if not (t_type == :literal or t_type == :bracket_start)
    failed = false
    #puts 'syntax validation'
    while position < (self.size - 1) and not failed and t_type != :bracket_end
      position += 1
      previous_type = t_type
      t_type = token_type(self[position])
    #  p t_type
      case t_type
      when :operator
        failed = true if previous_type == :operator or previous_type == :bracket_start
      when :literal
        failed = true if previous_type == :literal or previous_type == :bracket_end
      when :bracket_start
        if previous_type == :operator or previous_type == :bracket_start
          position = validate_syntax_p(position)
        else
          failed = true
        end
      when :bracket_end
        failed = true if not(previous_type == :literal or previous_type == :bracket_end)
      end
    end
    t_type = token_type(self[position])
    #puts 'validation ended'
    failed = true if not(t_type == :literal or t_type == :bracket_end)
    #p failed
    raise TaskSyntaxError.new(self) if failed
    return position
  end

  def validate_tokens *args
    args.each do |obj|
      raise ArgumentError.new(args) if token_type(obj) == :unknown
    end
    true
  end

  def operator? obj
    @@operators.include?(obj)
  end

  def literal? obj
    obj.kind_of?(Fixnum)
  end

  def bracket_end? obj
    obj.eql?(')')
  end

  def bracket_start? obj
    obj.eql?('(')
  end

  def token_type obj
    return :operator if operator?(obj)
    return :literal if literal?(obj)
    return :bracket_start if bracket_start?(obj)
    return :bracket_end if bracket_end?(obj)
    return :unknown
  end

  @@operators = [:+,:-,:*,:/]
end
