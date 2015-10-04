require 'task'
require 'task_builder'
require 'task_factory'

class TaskRoll

  def initialize user_name, config, &reporter
    @user_name = user_name
    @tasks = []
    @progress = {open: 0, passed: 0, failed: 0, attempts: 0}
    factory = TaskFactory.new(config)
    tasks = factory.tasks(&reporter)
    @progress[:open] = tasks.size
    tasks.each do |task|
      task.set_status_observer { |status| self.update_progress(status)}
      @tasks << task
    end
  end

  public

  def user
    @user_name
  end

  def each
    if block_given?
      @tasks.each { |task| yield task }
    else
      @tasks.each
    end
  end

  def reset
    each { |task| task.reset }
    @progress[:attempts] = 0
    self
  end

  def progress
    @progress
  end

  def success_ratio
    @progress[:attempts] != 0 ? @progress[:passed].to_f / @progress[:attempts] : 0
  end

  def shuffle!
    @tasks.shuffle!
  end

  def slice! ind1, ind2
    @tasks = @tasks.slice!(ind1,ind2)
  end

  def tasks
    @tasks
  end

  def self.create user_name, config, &reporter
    TaskRoll.new(user_name, config, &reporter)
  end


  def update_progress task_status_change
    @progress[task_status_change[0]] -= 1
    @progress[task_status_change[1]] += 1
    @progress[:attempts] += 1
  end
end
