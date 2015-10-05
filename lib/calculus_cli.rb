require "thor"
require "ansi/progressbar"
require_relative 'task_factory'
require_relative "factory_configurator"
require 'task_roll'
require_relative 'calculus_progressbar'

class String
  def is_number?
    true if Float(self) rescue false
  end
end

class CalculusCLI < Thor
  include Thor::Actions
  class_option  :name, required: true, type: :string, desc: 'user name'
  class_option :ranges, required: true, type: :hash, desc: 'opL:MIN opH:MAX reL:MIN reH:MAX --- a hash with min and max numbers to be used in tasks'
  class_option :operators, required: true, type: :array, desc: ':+ :- :/ :* operators to be used in tasks'
  class_option :opN, required: false, type: :numeric, default: 1, desc: 'maximum number of operators in a task'
  class_option :mixed, required: false, type: :boolean, default: false, desc: 'boolean, mix operators together in a task'


  desc "config --name 'NAME' --Ranges opL:0 opH:10 reL:0 reH:10 --OPERATORS :+ :- :/ :* --opN 2 --mixed", "validates configuration and generates the tasks."
  #disable_class_options
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
      print 'How many tasks do you want? '
      input_ok = false
      begin
        line = $stdin.readline()
        number = Integer(line)
        input_ok = true
      rescue ArgumentError
        puts "  .. Not a number, try it again."
        print 'How many tasks do you want? '
        next
      ensure
      end while not input_ok
      @task_roll.shuffle!
      @task_roll.slice!(0,number)
      @task_roll.each do |task|
        puts "#{task.to_s}"
      end
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
      exit
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

    > $ calculus go --name "Jiri Zoth" --Ranges opL:0 opH:10 reL:0 reH:10 --OPERATORS :+ :- :/ :* --opN 2 --mixed

    >
  LONGDESC
  #disable_class_options
  def go
    begin
    config { true } if not @task_roll
    puts "\e[2J"
    tasks = @task_roll.each
    #pbar = ANSI::Progressbar.new("(-: SCORE :-)",tasks.size )
    pbar = ::CalculusProgressbar.new("(-: SCORE :-)",tasks.size )
    #pbar.standard_mode
    pbar.bar_mark ".", "X", "ᗧ", "\u00B7"
    pbar.format("%-14s %3d%% |%s%s%s| %s", :title, :percentage, :bar_ok, :bar_current, :bar_todo, :stat)
    pbar.style(:title => [:blue], :bar_ok=>[:green], :bar_current => [:yellow], :bar_todo => [:white])
    print "\e[0;0H"
    pbar.inc(tasks.size * 0.01)
    task = tasks.next
    print "\e[8;21H"
    print "What is the result of?"

    #printf("export PS1='> '\n")
    mistake_couter = 0
    pbar.set(0)

    while true
      #print "\n"
      input_ok = false
      begin
        print "\e[10;20H", "\e[2K", '   '
        result = task.result?
        print task.to_s, ' '
        print "\e[s"
        line = $stdin.readline()
        print "\e[u"
        number = Integer(line)
        input_ok = true
      rescue ArgumentError
        print "\e[10;20H", "\e[2K", '   '
        print task.to_s, ' '
        print "\e[s"
        print "  .. Not a number, try it again."
        print "\e[u"
        `say "Not a number."`
        sleep(1)
        next
        #`echo -e \a`
      ensure
        #sleep(1)
      end while not input_ok

      begin
      if task.answer?(number)
        print "\e[s"
        print "\e[0;0H"
        pbar.inc 1, true
        print "\e[u"
        print "\e[s"
       # print "\e[10;39H"
        print '  .. Great!!!'
        print "\e[u"
        `say "Great!"`
        mistake_couter = 0
        task = tasks.next
     elsif mistake_couter < 2
        mistake_couter += 1
        #print "\e[10;39H"
        print "\e[s"
        print "  .. Wrong, try it again."
        print "\e[u"
        `say -v Whisper "Wrong, try it again."`
      else
        print "\e[s"
        print "\e[0;0H"
        pbar.inc 1, false
        print "\e[u"
        #print "\e[10;39H"
        print "\e[s"
        print "  .. Wrong."
        print "\e[u"
        `say -v Whisper "Wrong, next task."`
        mistake_couter = 0
        task = tasks.next
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
        break
      end
    end # while true
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


