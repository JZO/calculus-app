require 'task_builder'

class TaskSyntaxError < StandardError
end

class Task

  def initialize array
    raise ArgumentError.new("Can not initialize Task - expression data are not valid. #{array}") if not Task.valid_data? array
    @expresion_data = array.clone
    @status = :open
    @attempts = 0
    @observer_block = nil
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

  def to_s
    return @expresion_data.join(' ') + ' = '
  end

  def answer? result
    @result = result? if not @result
    @result == result ? status(:passed) : status(:failed)
    return @status == :passed
  end

  def status?
    return @status
  end

  def attempts
    @attempts
  end

  def reset
    status(:open)
    @attempts = 0
  end

  def set_status_observer &observer
    @observer_block = observer if block_given?
  end

  private
  def status new_status
    p_state = @status
    @attempts += 1
    @status = new_status
    @observer_block.call([p_state,@status,@attempts]) if @observer_block
  end



end
