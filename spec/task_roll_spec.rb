require 'task_builder'
require 'task_factory'
require 'task'
require 'task_roll'
require 'factory_girl'


RSpec.describe TaskRoll do

  describe '#user' do
    context 'when created' do
      subject { build(:task_roll).user }
      it 'has a user name' do
        is_expected.not_to be_nil
      end
    end
  end

  describe '#each' do
    context 'when no block provided' do
      subject { build(:task_roll).each }
      it { is_expected.to be_kind_of(Enumerator) }
      it { is_expected.to all( satisfy { |task| Task.valid_data?(task.to_arry) } ) }
    end

    context 'when block is provided' do
      subject { build(:task_roll) }
      specify { expect { |b| subject.each(&b) }.to yield_successive_args(*subject.tasks) }
    end
  end

  describe '#progress' do
    context 'when a task change' do
      subject { build(:task_roll) }
      let(:itr) { subject.each }
      it {
        expect(subject.progress).to match a_hash_including(open: 51,passed: 0, failed: 0)
      }
      it {
        itr.next.answer?(-1)
        expect(subject.progress).to match a_hash_including(open: 50,passed: 0, failed: 1)
      }

      it {
        itr.next.answer?(-1)
        itr.next.answer?(5)
        expect(subject.progress).to match a_hash_including(open: 49,passed: 1, failed: 1)
      }
    end
  end

  describe '#reset' do
    context 'when reset called' do
      subject { build(:task_roll) }
      let(:itr) { subject.each }
      it {
        itr.next.answer?(-1)
        itr.next.answer?(5)

        expect(subject.reset.progress).to match a_hash_including(open: 51, passed: 0, failed: 0)
      }
    end
  end

  describe '#success_ratio' do
    context 'when a task status change' do
      subject { build(:task_roll) }
      let(:itr) { subject.each }
      it {
        itr.next.answer?(-1)
        task = itr.next
        task.answer?(2)
        task.answer?(4)
        task.answer?(5)
        puts "task roll progress #{subject.progress}"
        expect(subject.success_ratio).to eql(0.25)
      }
    end
  end



end

