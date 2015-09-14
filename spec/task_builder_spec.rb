require 'task_builder'
require 'task'

RSpec.describe TaskBuilder do

  context 'Task Builder' do
    let(:task_valid_tokens) { [1,2,3,4,5,6,7,8,9,0,:+,:-,:*,:/,'(',')']}
    let(:task_invalid_tokens) { ['@', :==, :call, :h, 's'] }
    let(:task_invalid_expansion) {
      [
        [:+, 'b',1]
      ]
    }
    let(:task_valid_expansion) {
      [
        [[1,:+,2,:*,4],[:+, 2, 1],[1,:+,2,:*,'(',2,:+,1,')']],
        [[1,:+,2,:*,4],[:*, 3, 4],[1,:+,2,:*,3,:*,4]],
        [[1,:+,2,:*,4],[:/, 4, 2],[1,:+,2,:*,4,:/,2]]
      ]
    }



    describe 'token tests' do
      let(:task_builder) {TaskBuilder.new}

      it 'push works for allowed tokens.' do
        task_valid_tokens.each_with_index do |token,i|
          expect( task_builder.push(token)).to eql(task_valid_tokens.slice(0,i+1))
        end
      end

      it 'push fails for illegal characters' do
        task_invalid_tokens.each_with_index do |character,i|
          expect { task_builder.push(character)}.to raise_error(ArgumentError)
        end
      end

      it 'fails to expand with illegal tokens' do
        task_builder.concat([1,:+,2])
        task_invalid_expansion.each_with_index do |exp,i|
          expect { task_builder.expand_operand(2, exp[0], exp[1], exp[2])
}.to raise_error(ArgumentError)
        end
      end
    end

    describe 'creates a Task object when' do
      let(:task_builder) {TaskBuilder.new([1,:+,3])}
      it 'the builder object contains a valid data' do
        expect(task_builder.task).to be_a_kind_of(Task)
      end
    end

    describe 'fails to create a task object when' do
      let(:task_builder) {TaskBuilder.new([1,:+,3,1])}
      it 'the builder object contains wrong tokens' do
        expect { task_builder.task}.to raise_error(TaskSyntaxError)
      end
    end

    describe 'expands with valid tokens' do
      it 'replace correctly last token' do
        task_valid_expansion.each do |exp|
          task_builder = TaskBuilder.new(exp[0])
          i = task_builder.size
          expect(task_builder.expand_operand(i - 1, exp[1][0], exp[1][1], exp[1][2])
                ).to eql(exp[2])
        end
      end
    end

    describe 'provides utility functions for:' do
      let(:task_builder) {TaskBuilder.new([1,:+,4,:*,8,:-,3]) }
      it 'returns an index of maximum operand' do
        expect(task_builder.max_operand_index).to eql(4)
      end

      it 'has a list of allowed operators' do
        expect(TaskBuilder.operators).to eql([:+,:-,:*,:/])
      end
    end
  end

end
