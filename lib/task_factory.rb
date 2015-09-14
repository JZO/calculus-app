# #!/usr/bin/ruby

require 'task'
require 'task_builder'

class FactoryConfigError < StandardError
end

class FactoryError < StandardError
end

#operand range, result range, number of operands, operations used
class TaskFactory

   public

   def config_keys
     @config_keys
   end

   def config *conf
    @config = conf[0] if conf.size > 0 and validate_config(conf[0])
    @config
   end

   def tasks
     validate_config(config)
     #generate an array of tasks objects
     #call private recursive method with parameters

     # take parameters from config - fill default values
     # and call private recursive method
     # take result and return it

     req_operators = [:+]
     max_operands = 1
     mixed_operators = false

     req_operators = config[:required_operators] if config.include?(:required_operators)
     max_operands = config[:max_operands] if config.include?(:max_operands)
     mixed_operators = config[:mixed_operators] if config.include?(:mixed_operators)
     result_range = config[:result_range]
     tasks = Array.new
     result_range.each do |result|
       #task = TaskBuilder.new.push(result)
       task = nil
       tasks += generate_tasks(result, task, req_operators, max_operands, mixed_operators, config[:operand_range])
     end
     result = Array.new
     puts 'converting builders to tasks'
     tasks.each do |task_builder|
       result.push(task_builder.task)
     end
     return result
   end

   private

   @config_keys = [ :required_operators, :max_operands, :mixed_operators, :result_range, :operand_range]

   @config = nil

   def validate_config(conf)
     raise FactoryConfigError.new('config object is nil') if conf == nil

     # 1. mandatory keys exists
     # 2. object types for mandatory keys are correct
     # 3. values for each key are correct

     raise FactoryConfigError.new('config is not a hash.') if not conf.kind_of?(Hash)

     valid = true
     b_result_range = false
     b_operand_range = false

     conf.each_pair do |key, value|
       case key
       when :required_operators
         operators = TaskBuilder.operators
         if (not value.kind_of?(Array)) or value.length == 0
           valid = false
           break
         end
         count = 0
         value.each do |operator|
           count += 1 if operators.include?(operator)
         end
         if count != value.length
           valid = false
           break
         end
       when :max_operands
         if (not value.kind_of?(Fixnum)) or value > 5
           valid = false
           break
         end
       when :mixed_operators
         if not( not (value)) == value
         else
           valid = false
           break
         end
       when :result_range
         if value.kind_of?(Range) and value.size > 0 and value.min.kind_of?(Fixnum) and value.max.kind_of?(Fixnum)
           b_result_range = true
         else
            valid = false
            break
         end
       when :operand_range
         if value.kind_of?(Range) and value.size > 0 and value.min.kind_of?(Fixnum) and value.max.kind_of?(Fixnum)
           b_operand_range = true
          else
            valid = false
            break
         end
       else
         raise FactoryConfigError.new('unknown config key: ' + key)
       end
     end

     if(valid and b_result_range and b_operand_range)
       return true
     else
         raise FactoryConfigError.new('Mandatory keys missing or values are not correct.')
     end
   end

   def generate_tasks(result, in_task, operators, operands, mixed, operand_range)
     return [] if operands < 1 or operators.length < 1
     # or task == nil
     task = in_task
     temporary_tasks = Array.new
     puts "number of operators: #{operators.size}"
     if task == nil
       task = TaskBuilder.new
       task.push(result)
     end
     last_operator = task.last_operator
     operators.each do |operator|
      if last_operator != nil and not mixed and not operator.eql?(last_operator)
        next
      else
        temporary_tasks += expand_task_with(task, result, operator, operand_range)
      end
     end
     return temporary_tasks if operands <= 1
     # expanded_tasks = Array.new
         #calculate optimized operand_range and pass it down
         # if mixed how to mix operators?
     # # if not mixed expand only tasks with matching operator
     temporary_tasks.each do |task|
         temporary_tasks += generate_tasks(result,task,operators,(operands -1), mixed, operand_range)
     end
     return temporary_tasks
   end

  def expand_task_with t_task, result, operator, operand_range
    tasks = Array.new
    puts '............................................'
    puts "expanding #{t_task} ......"
    t_max_index = t_task.max_operand_index
    t_max = t_task[t_max_index]
    factors = factorize(t_max, operator, operand_range)
    factors.each do |values|
      task = TaskBuilder.new(t_task)
      task.expand_operand(t_max_index, operator, values[1], values[0])
      puts 'expanded tasks'
      p task
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

  def self.substractionSet resultRange, operandRange
    tasks = Array.new

    operandRange.each do |operand|
      resultRange.each do |result|
        tasks.push [operand, operand - result]
      end
    end
    tasks
  end

  def self.shuffleOperands tasks
    rand = Random.new
    tasks.each do |task|
      task[0], task[1] = task[1], task[0] if rand(2) == 1
    end
    tasks
  end

  def self.increaseNumberOfOperands count, task
    if (task.size < count) and (task.max > 1)
      self.increaseNumberOfOperands count - 1, task if (task.size < count) and (task.max > 1)
      index =  task.each_with_index.max_by {|e,i| e}.last
      rand = Random.new
      operand = rand.rand(task[index])

      if task.index(0)
        while operand == 0 do
          operand = rand.rand(task[index])
        end
      end
      task[index] = task[index] - operand
      task.push operand
    end
  end

  def self.populateTasksWithOperands count, tasks
    rand = Random.new
    tasks.each do |task|
      self.increaseNumberOfOperands rand.rand(count + 1), task
    end
    tasks
  end

# end

  def createAdditionTasks
  tasks = Generator.additionSet 10, 3
  Generator.populateTasksWithOperands 5, tasks
  tasks = Generator.shuffleOperands tasks
  Generator.increaseNumberOfOperands 3, tasks[0]
  tasks
  end

  def createSubstractionTasks
  tasks = Generator.substractionSet( (3..7), (7..10))

  end

  def printTasks tasks, operand
  tasks.each { |task|
    puts "#{task[0]} #{operand} #{task[1]} = "
  }
  end

  def runTestTasks tasks, operand
  tasks.each { |task|
    puts "#{task[0]} #{operand} #{task[1]} = "
    #puts task[0].public_send(operand, task[1])
    result = gets.chomp
    return if result == 'close'
    if result == task[0].public_send(operand, task[1]).to_s
      puts 'perfect'
    else
      puts 'wrong'
    end
  }
  end

end
# cmd = ''
# tasks = nil
# operand = ''


# until 'quit' == cmd do
# p 'waiting...'
# cmd = gets.chomp
# puts 'echo: ' + cmd
#
# case cmd
#   when 'addition'
#     tasks = createAdditionTasks
#     operand = :+
#     printTasks tasks, '+'
#   when 'substraction'
#     tasks = createSubstractionTasks
#     operand = :-
#     printTasks tasks, '-'
#   when 'run'
#     runTestTasks tasks, operand
#   when 'quit'
#   else
#     puts 'unknown command'
# end


