require "ansi/progressbar"

class CalculusProgressbar < ANSI::Progressbar

  def inc step, *status
    @attempts_record ||= Array.new
    @attempts_record += status if status and step == 1
    super step
  end

  def bar_mark ok_mark, failed_mark, current_mark, todo_mark
    @bar_mark = String(ok_mark)[0..0]
    @failed_mark = String(failed_mark)[0..0]
    @current_mark = String(current_mark)[0..0]
    @todo_mark = String(todo_mark)[0..0]
  end

  def bar_ok
    len = percentage * @bar_length / 100
    if len <= 1
      sprintf("%s", "")
    else
      #sprintf("%s", @bar_mark * len)

      #get list of results, recalculate results per mark, e.q. buckets - if a bucket contains failed result it draws failed character
      if @attempts_record.size > len
        bucket_size = @attempts_record.size / len
        cx = 1
      else
        bucket_size = 1
        cx = len / @attempts_record.size
      end
      line = ""
      @attempts_record.each_slice(bucket_size) do |bucket|
        if bucket.any? {|status| status}
          line += @bar_mark * cx
        else
          line += colorize(@failed_mark * cx, :red)
        end
      end
      sprintf("%s", line)
    end
  end

  def bar_todo
    len = percentage * @bar_length / 100
    count = @bar_length - len - 1
    sprintf("%s", count < 0 ? "" : (@todo_mark * count))
  end

  def bar_current
    if percentage < 100 and not @is_finished
      sprintf("%s", @current_mark.to_s)
    else
      sprintf("%s","")
    end
  end
def show_progress
  if @total.zero?
    cur_percentage = 100
    prev_percentage = 0
    show
  else
    cur_percentage  = (@current  * 100 / @total).to_i
    prev_percentage = (@previous * 100 / @total).to_i
  end
  if cur_percentage > prev_percentage || @is_finished
    show
  end
end
  def show
    arguments = @format_arguments.map do |method|
      colorize(send(method), styles[method])
    end
    line      = sprintf(@format, *arguments)
    width     = get_width
    length    = ANSI::Code.uncolor{line}.length
    if length == width - 1
      @out.print(line + eol)
    elsif length >= width
      @bar_length = [@bar_length - (length - width + 1), 0].max
      @bar_length == 0 ?  @out.print(line + eol) : show
    else #line.length < width - 1
      @bar_length += width - length + 1
      show
    end
  end
end
