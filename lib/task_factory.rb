require 'task'
require 'task_builder'
require 'factory_configurator'

class FactoryConfigError < StandardError
end

class FactoryError < StandardError
end

class TaskFactory

   public

   def initialize configurator
     @config = configurator if configurator.valid? and configurator.kind_of?(FactoryConfigurator)
   end

   def tasks &reporter
     @config.valid?
     @reporter = reporter
     req_operators = @config[:required_operators]
     max_operands = @config[:max_operands]
     mixed_operators = @config[:mixed_operators]
     result_range = @config[:result_range]
     @estimated_cycles = req_operators.size * max_operands.size * result_range.size
     @actual_cycles = 0
     tasks = Array.new
     result_range.each do |result|
       #task = TaskBuilder.new.push(result)
       task = nil
       tasks += generate_tasks(result, task, req_operators, max_operands, mixed_operators, @config[:operand_range])
     end
     result = Array.new
     #puts 'converting builders to tasks'
     tasks.each do |task_builder|
       result.push(task_builder.task)
     end
     return result
   end

   private

   def generate_tasks(result, in_task, operators, operands, mixed, operand_range)
     return [] if operands < 1 or operators.length < 1
     # or task == nil
     task = in_task
     temporary_tasks = Array.new
     #puts "number of operators: #{operators.size}"
     if task == nil
       task = TaskBuilder.new
       task.push(result)
     end
     last_operator = task.last_operator
     operators.each do |operator|
       #puts "operator #{operator}"
      if last_operator != nil and not mixed and not operator.eql?(last_operator)
        next
      else
        temporary_tasks += expand_task_with(task, result, operator, operand_range)
      end
      @actual_cycles += 1
      @reporter.call((@actual_cycles.to_f / @estimated_cycles * 100).to_i) if @reporter
     end
     return temporary_tasks if operands <= 1
     temporary_tasks.each do |task|
         temporary_tasks += generate_tasks(result,task,operators,(operands -1), mixed, operand_range)
     end
     return temporary_tasks
   end

  def expand_task_with t_task, result, operator, operand_range
    tasks = Array.new
    #puts '............................................'
    #puts "expanding #{t_task} ......"
    t_max_index = t_task.max_operand_index
    t_max = t_task[t_max_index]
    factors = factorize(t_max, operator, operand_range)
    factors.each do |values|
      task = TaskBuilder.new(t_task)
      task.expand_operand(t_max_index, operator, values[1], values[0])
      #puts 'expanded tasks'
      #p task
      tasks << task
    end
    tasks
  end

  def factorize number, operator, operand_range
    factors = Array.new
    #inv_operator = invert_operator(operator)
    operand_range.each do |operand|
      case operator
      when :+
        if 2 * operand_range.min <= number and number <= 2 * operand_range.max
          op2 = number.public_send(invert_operator(operator), operand)
          if operand_range.include?(op2)
            factors.push([operand,op2])
          end
        elsif
          (
           number.abs >= operand.abs
          )
           op2 = number.public_send(invert_operator(operator), operand)
           factors.push([operand,op2])
        end
      when :-
        if operand_range.min - operand_range.max <= number and number <= operand_range.max - operand_range.min
           op2 = number.public_send(invert_operator(operator), operand)
           # if operand_range.include?(op2)
           #factors.push([operand,op2])
           if operand_range.include?(op2)
             factors.push([operand,op2])
           end
           # end
        elsif number.abs <= operand.abs
           op2 = number.public_send(invert_operator(operator), operand)
           factors.push([operand,op2])
        end
      when :*
        next if operand == 0
        tr = number.divmod(operand)
        if tr[1] == 0
          factors.push([operand,tr[0]])
        end
      when :/
        next if operand == 0
        op2 = number * operand
        factors.push([operand,op2]) if operand_range.include?(op2) or operand.abs == 1
      else
        raise FactoryError.new
      end
    end
    return factors
  end

  def invert_operator operator
    case operator
    when :+
      return :-
    when :-
      return :+
    when :*
      return :/
    when :/
      return :*
    else
      raise FactoryError.new
    end
  end

end


