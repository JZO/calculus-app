class Task

  def initialize array
    raise ArgumentError.new('Can not initialize Task - expression data are not valid.') if not Task.valid_data? array
    @expresion_data = array.clone
    @passed = :none
    self
  end

  def self.valid_data? array
    return false if array == nil or array.length == 0
    p_token_type = :none
    bad_tokens = array.reject { |token|
      bad_token = true
      token_type = false
      if token.class.eql?(Fixnum)
        token_type = :numeric
      elsif ['+','-','*','/'].include?(token)
          token_type = :operator
      else
        token_type = :invalid
        #lexically bad token found
      end

      case p_token_type
        when :none
          p_token_type = token_type
          bad_token = token_type != :numeric
        when :numeric
          p_token_type = token_type
          bad_token = token_type != :operator
        when :operator
          p_token_type = token_type
          bad_token = token_type != :numeric
        else
          p_token_type = token_type
          bad_token = true
        end
     not  bad_token
    }
    return bad_tokens.length == 0
  end

  def result?
    return instance_eval(@expresion_data.join(' '))
  end

  def answer? result
    if not @result
      @result = result?
      @result == result ? @passed = :passed : @passed = :failed
    end
    return @result == result
  end

  def passed?
    return @passed
  end

  def reset
    @passed = :none
  end
end
