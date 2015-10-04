require "thor"
require "ansi/progressbar"
require_relative 'task_factory'
require_relative "factory_configurator"
require 'task_roll'

class String
  def is_number?
    true if Float(self) rescue false
  end
end

class CalculusCLI < Thor
  include Thor::Actions
  class_option  :name, required: true, type: :string
  class_option :ranges, required: true, type: :hash
  class_option :operators, required: true, type: :array
  class_option :opN, required: false, type: :numeric, default: 1
  class_option :mixed, required: false, type: :boolean, default: false


  desc "config --name 'NAME' --Ranges opL:0 opH:10 reL:5 reH:10 --OPERATORS +,-,/,* --opN 2 --mixed", "validates configuration and generates the tasks."
  def config
    begin
      tested_key = 'opL opH reL reH'
      unless options[:ranges] and options[:ranges].all? { |key, value| tested_key = key; ['opL','opH', 'reL','reH'].include?(key) and value.is_number?}
        raise RequiredArgumentMissingError.new("'--Ranges' shall contain only allowed keys.  #{tested_key} is incorrect or has not a numeric value.")
      end

      unless options[:operators] and options[:operators].all? { |op| ['+','-','/','*'].include?(op[1]) }
        raise RequiredArgumentMissingError.new("'--Operators' requires only :+,:-,:/,:* values.")
      end

      config = FactoryConfigurator.options_2_conf(options)

      puts 'Configuration validated.'
      puts 'Generating tasks ...'
      @task_roll = TaskRoll.create(options[:name],config) { |percent| print_progress_bar(percent) }
      print_progress_bar(100)
      puts
      say("Configuration ..... done. Number of tasks generated: #{@task_roll.tasks.size}")
      puts 'How many tasks do you want?'
      line = $stdin.readline()
      number = Integer(line)
      @task_roll.shuffle!
      @task_roll.slice!(0,number)
      if not yes?('Continue?')
        exit
      elsif block_given?
        if not yield
          puts 'Stopped by callee.'
          exit
        end
      else
        go
      end
    rescue Interrupt
      puts
      puts "Exiting ..."
    end
    return
  end

  desc "go", "Starts calculus game with provided options NAME, RANGES, OPERATORS, opN and MIXED."
   long_desc <<-LONGDESC
    `calculus go` takes --NAME and --RANGES --OPERATORS --opN --MIXED options. It generates tasks and starts the game in an interactive shell.

    Required options are:

    --name option, calculus will use provided <name> in communication

    --RANGES option, calculus will generate tasks using operands between opL..opH range and results falling into reL and reH range.

    --OPERATORS option, calculus will generate tasks with operators set in the array

    Optional options are:

    --opN option, calculus will generate tasks with number of operators up to the number

    --MIXED option, if set calculus will generate tasks with combined operators from OPERATORS option

    > $ calculus go --name "Jiri Zoth" --Ranges opL:0 opH:10 reL:5 reH:10 --OPERATORS +,-,/,* --opN 2 --mixed

    >
  LONGDESC

  def go
    begin
    config { true } if not @task_roll
    puts "\e[2J"
    tasks = @task_roll.each
    pbar = ANSI::Progressbar.new("(-: SCORE :-)",tasks.size )
    #pbar.standard_mode
    pbar.bar_mark = "ᗧ"
    pbar.format("%-14s %3d%% %s %s", :title, :percentage, :bar, :stat)
    pbar.style(:title => [:blue], :bar=>[:green])
    print "\e[0;0H"
    pbar.inc(tasks.size * 0.01)
    task = tasks.next
    print "\e[8;21H"
    print "What is a result of?"

    #printf("export PS1='> '\n")
    mistake_couter = 0
    pbar.set(0)
    begin
    while true
      #print "\n"
      print "\e[10;20H", "\e[2K", ' > '
      result = task.result?
      print task.to_s, ' '
      line = $stdin.readline()
      print "\e[10;32H"
    begin
        # Convert string to integer.
        number = Integer(line)
        if task.answer?(number)
          print '  .. Great!!!'
          `say "Great!"`
          task = tasks.next
        elsif mistake_couter < 2
          mistake_couter += 1
          print "  .. Wrong, try it again."
          `say -v Whisper "Wrong, try it again."`
        else
          print "  .. Wrong."
          `say -v Whisper "Wrong, next task."`
          mistake_couter = 0
          task = tasks.next
        end
        print "\e[0;5H"
        pbar.inc
    rescue ArgumentError
      print "  .. Not a number, try it again."
      `echo -e \a`
    ensure
      sleep(1)
    end
    end
    rescue StopIteration
      puts "\e[2J"
      print "\e[0;0H"
      pbar.finish
      print "\e[10;20H"
      print "!!!!!  CONGRATULATIONS  !!!!!"
      $stdin.readline()
      puts "\e[2J"
      print "\e[0;0H"
    end
    rescue Interrupt
      puts
      puts "Exiting ... ᗧ ○◯     ◯  ◯ ᗣ "
    end
    return
  end
  default_task :go

end

def print_progress_bar finished_percent
    fixed_space = 10 # for braces and number
    width = `tput cols`.to_f - fixed_space
    finished_percent = 100 if finished_percent > 100
    finished_count = ((finished_percent*width)/100).ceil
    empty_count    = width - finished_count
    finished = "#" * finished_count
    empty    = "-" * empty_count
    print "\r[ #{finished}#{empty} ] #{finished_percent}% "
end


