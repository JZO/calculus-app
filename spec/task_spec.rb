require 'task'


RSpec.describe Task do
  context "Task creation fails when:" do
    it 'is created without data in Array' do
      expect {Task.new}.to raise_error(ArgumentError)
    end

    it 'is created with non-valid data' do
      expect {Task.new([])}.to raise_error(ArgumentError)
      expect {Task.new([1,1])}.to raise_error(ArgumentError)
      expect {Task.new [+1,'+',-2,'s']}.to raise_error(ArgumentError)
    end
  end

  context "Task can:" do
    let(:task) { Task.new [1,'+',2,'+',-2,'+',1] }

    it "give an expected/correct result." do
      expect( task.result?).to eq(2)
    end

    it "respond true for a correct answer" do
      expect( task.answer?(2) ).to eq(true)
    end
  end

  context "Task's behavior depends on its state:" do
    let(:task) { Task.new [1,'+',2,'+',-2,'+',1] }

    it "Task has :none state before first call to answer." do
      expect( task.passed? ).to eq(:none)
    end

    it "Task is :failed when it is answered incorrectly" do
      task.answer?(3)
      expect( task.passed? ).to eq(:failed)
    end

    it "Task can not change state when :failed" do
      task.answer?(3)
      task.answer?(2)
      expect( task.passed? ).to eq(:failed)
    end

    it "Task's state returns to :none when reseted." do
      task.answer?(3)
      task.reset
      expect( task.passed? ).to eq(:none)
    end

    it "Task is :passed when it is answered with correct result." do
      task.answer?(2)
      expect( task.passed? ).to eq(:passed)
    end

    it "Task can not change state when :passed." do
      task.answer?(2)
      task.answer?(3)
      expect( task.passed? ).to eq(:passed)
    end

 end
end


