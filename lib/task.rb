require 'task_builder'

class TaskSyntaxError < StandardError
end

class Task

  def initialize array
    raise ArgumentError.new("Can not initialize Task - expression data are not valid. #{array}") if not Task.valid_data? array
    @expresion_data = array.clone
    @passed = :none
    self
  end

  def self.valid_data? array
    return false if array == nil or array.length == 0
    valid = false
    begin
      builder = TaskBuilder.new(array)
      valid = builder.ok?
    rescue TaskSyntaxError
      valid = false
    end
    return valid
  end

  def result?
    return instance_eval(@expresion_data.join(' '))
  end

  def to_arry
    return @expresion_data.clone
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
