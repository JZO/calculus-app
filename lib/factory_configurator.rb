require 'thor'

class FactoryConfigurator

  public

   def initialize conf
     @config = conf if validate_config(conf)
     self
   end

   def [](key)
     @config[key]
   end

   def self.options_2_conf options
     config = {}
     options.each_pair do |key, value|
       case key.to_sym
       when :ranges
         unless value.all? { |key, value| tested_key = key; ['opL','opH', 'reL','reH'].include?(key) and value.is_number?}
           raise Thor::RequiredArgumentMissingError.new("'--Ranges' shall contain only allowed keys.  #{tested_key} is incorrect or has not a numeric value.")
         end
         operand_range = (value['opL'].to_i .. value['opH'].to_i)
         result_range = (value['reL'].to_i .. value['reH'].to_i)
         config[:operand_range] = operand_range
         config[:result_range] = result_range
       when :operators
         operators = []
         unless value.all? { |op|
           if ['+','-','/','*'].include?(op[1])
             operators << op[1].to_sym
             true
           else
             false
           end
         }
           raise Thor::RequiredArgumentMissingError.new("'--Operators' requires only :+,:-,:/,:* values.")
         end
         config[:required_operators] = operators
       when :opN
         config[:max_operands] = value.to_i
       when :mixed
         config[:mixed_operators] = value
       when :name
       else
         raise Thor::RequiredArgumentMissingError.new("Unknown option  #{key}.")
       end
     end
     FactoryConfigurator.new(config)
   end

   def valid?
     validate_config(@config)
   end

  private

   @config_keys = [ :required_operators, :max_operands, :mixed_operators, :result_range, :operand_range]

   @config = nil

   def config_keys
     @config_keys
   end

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

end

