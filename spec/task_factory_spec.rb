require 'task_factory'
require 'task'

RSpec.describe TaskFactory do
  let(:factory_valid_data) { [1,2,3,4,5,6,7,8,9,0,:+,:-,:*,:/]}
  let(:factory_invalid_data) { ['@', :==, :call, :h, 's'] }

  let(:config_keys) { [ :required_operators, :max_operands, :mixed_operators, :result_range, :operand_range] }
  let(:factory_valid_config) { { required_operators: [:+,:-], max_operands: 4, mixed_operators: false, result_range: (5..10), operand_range:(0..10)} }

  let(:factory_invalid_config) { { required_operators: [:+,:-], max_operands: 4, mixed_operators: false, result_range: (10..5), operand_range:(0..10)} }


  let(:test_config_data_1) { { required_operators: [:+], max_operands: 1, mixed_operators: false, result_range: (5..10), operand_range:(0..10)} }

  let(:test_config_data_2) { { required_operators: [:+], max_operands: 2, mixed_operators: false, result_range: (9..10), operand_range: (0..2)} }

  let(:test_config_data_3) { { required_operators: [:+], max_operands: 2, mixed_operators: false, result_range: (10..10), operand_range: (9..10)} }

  let(:test_config_data_4) { { required_operators: [:+], max_operands: 2, mixed_operators: false, result_range: (-5..3), operand_range: (-2..1)} }

  let(:test_config_data_minus_1) { { required_operators: [:-], max_operands: 1, mixed_operators: false, result_range: (5..10), operand_range:(0..10)} }

  let(:test_config_data_minus_2) { { required_operators: [:-], max_operands: 2, mixed_operators: false, result_range: (9..10), operand_range: (0..2)} }

  let(:test_config_data_minus_3) { { required_operators: [:-], max_operands: 2, mixed_operators: false, result_range: (9..10), operand_range: (0..10)} }

  let(:test_config_data_minus_4) { { required_operators: [:-], max_operands: 2, mixed_operators: false, result_range: (-5..3), operand_range: (-2..1)} }

  let(:test_config_data_plus_minus_1) { { required_operators: [:+,:-], max_operands: 2, mixed_operators: true, result_range: (-5..3), operand_range: (-2..1)} }

  let(:test_config_data_mlp_1) { { required_operators: [:*], max_operands: 2, mixed_operators: false, result_range: (-5..3), operand_range: (-2..1)} }

  let(:test_config_data_divmod_1) { { required_operators: [:/], max_operands: 2, mixed_operators: false, result_range: (-5..3), operand_range: (-2..1)} }

  let(:test_config_data_mlp_divmod_1) { { required_operators: [:*,:/], max_operands: 2, mixed_operators: true, result_range: (-5..3), operand_range: (-2..1)} }

  let(:test_config_data_all_1) { { required_operators: [:+,:-,:*,:/], max_operands: 2, mixed_operators: true, result_range: (-5..3), operand_range: (-2..1)} }


  let(:test_result_data_1) {
    [
      [10,:+,0],[9,:+,1],[8,:+,2],[7,:+,3],[6,:+,4],[5,:+,5],[4,:+,6],[3,:+,7],[2,:+,8],[1,:+,9],[0,:+,10],
      [9,:+,0],[8,:+,1],[7,:+,2],[6,:+,3],[5,:+,4],[4,:+,5],[3,:+,6],[2,:+,7],[1,:+,8],[0,:+,9],
      [8,:+,0],[7,:+,1],[6,:+,2],[5,:+,3],[4,:+,4],[3,:+,5],[2,:+,6],[1,:+,7],[0,:+,8],
      [7,:+,0],[6,:+,1],[5,:+,2],[4,:+,3],[3,:+,4],[2,:+,5],[1,:+,6],[0,:+,7],
      [6,:+,0],[5,:+,1],[4,:+,2],[3,:+,3],[2,:+,4],[1,:+,5],[0,:+,6],
      [5,:+,0],[4,:+,1],[3,:+,2],[2,:+,3],[1,:+,4],[0,:+,5]
    ]
  }

let(:test_result_data_2) {
    [
      [10,:+,0],
      [10, :+, 0, :+, 0],
      [9,:+,1],
      [9, :+, 1, :+, 0],[9,:+,0,:+,1],[8,:+,1,:+,1],[7,:+,2,:+,1],
      [8,:+,2],
      [8, :+, 2, :+, 0],[8,:+,0,:+,2],[7,:+,1,:+,2],[6,:+,2,:+,2],
      [9,:+,0],
      [9, :+, 0, :+, 0],
      [8,:+,1],
      [8, :+, 1, :+, 0],[8,:+,0,:+,1],[7,:+,1,:+,1],[6,:+,2,:+,1],
      [7,:+,2],
      [7, :+, 2, :+, 0],[7,:+,0,:+,2],[6,:+,1,:+,2],[5,:+,2,:+,2]
    ]
  }

let(:test_result_data_3) {
    [
      [1,:+,9],[0,:+,10],
      [1, :+, 0, :+, 9],
      [0, :+, 1, :+, 9],
      [0, :+, 0, :+, 10]
    ]
  }

let(:test_result_data_4) {
    [
      [1,:+,9],[0,:+,10],
      [1, :+, 0, :+, 9],
      [0, :+, 1, :+, 9],
      [0, :+, 0, :+, 10]
    ]
  }

 let(:test_result_data_minus_1) {
    [
      [5, :-, 0],
      [6, :-, 1],
      [7, :-, 2],
      [8, :-, 3],
      [9, :-, 4],
      [10, :-, 5],
      [6, :-, 0],
      [7, :-, 1],
      [8, :-, 2],
      [9, :-, 3],
      [10, :-, 4],
      [7, :-, 0],
      [8, :-, 1],
      [9, :-, 2],
      [10, :-, 3],
      [8, :-, 0],
      [9, :-, 1],
      [10, :-, 2],
      [9, :-, 0],
      [10, :-, 1],
      [10, :-, 0]
    ]
  }

 let(:test_result_data_minus_2) {
    [
    ]
  }

 let(:test_result_data_minus_3) {
    [
 [9, :-, 0],[10, :-, 1],[9, :-, 0, :-, 0],
 [10, :-, 1, :-, 0],[10, :-, 0, :-, 1],[10, :-, 0],[10, :-, 0, :-, 0]
    ]
  }

 let(:test_result_data_minus_4) {
    [
    ]
  }

let(:test_result_data_plus_minus_1) {
    [
    ]
  }

let(:test_result_data_mlp_1) {
    [
    ]
  }

let(:test_result_data_divmod_1) {
    [
    ]
  }

let(:test_result_data_mlp_divmod_1) {
    [
    ]
  }

 let(:test_result_data_all_1) {
    [
    ]
  }

 context 'is supplied with incorrect input values.' do
      let(:task_factory) {TaskFactory.new}

      it 'Factory can not be configured.' do
        expect {task_factory.config(factory_invalid_config)}.to raise_error(FactoryConfigError)
      end
      it 'Factory can not produce task objects.' do
        expect {task_factory.tasks}.to raise_error(FactoryConfigError)
      end

      it 'Factory preserves old configuration.' do
        task_factory.config(factory_valid_config)
        expect {task_factory.config(factory_invalid_config)}.to raise_error(FactoryConfigError)
        config = task_factory.config
        expect(config).to eql(factory_valid_config)
      end
  end

  context 'is supplied with correct config values.' do
      let(:task_factory) {TaskFactory.new}

      it 'Factory shall create an array of valid task objects.' do
        task_factory.config(factory_valid_config)
        task_factory.tasks.each do |task|
          expect(task).to be_a_kind_of(Task)
        end
      end

      it 'All tasks shall conform to the configuration. -- skipped --' do
        skip
        task_factory.config(factory_valid_config)
        task_factory.tasks.each do |task|
          #yet to be decided -- implementation of the test is quite complicated
        end
      end
  end

  context 'it generates all combinations for given config' do
    let(:task_factory) {TaskFactory.new}
    def test_data_matcher test_data, tasks
      return tasks.length if test_data.length != tasks.length
      tasks.each do |task|
        return task.to_arry if not test_data.include?(task.to_arry)
      end
      true
    end
    it '+ operator for 1 operator', :plus_only do
      task_factory.config(test_config_data_1)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_1,tasks)
      expect(match).to eql(true)
    end

    it '+ operator for 2 operators', :plus_only do
      task_factory.config(test_config_data_2)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_2,tasks)
      expect(match).to eql(true)
    end

    it '+ operator for 2 operators, misplaced op range', :plus_only do
      task_factory.config(test_config_data_3)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_3,tasks)
      expect(match).to eql(true)
    end

    it '+ operator for 2 operators, with negative/positive op range', :plus_only do
      task_factory.config(test_config_data_4)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_4,tasks)
      expect(match).to eql(96)
    end

    it '1 (-) operator', {minus_only: true , focus: false} do
      task_factory.config(test_config_data_minus_1)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_minus_1,tasks)
      expect(match).to eql(true)
    end

  it 'disjoint operand range and result range shall have 0 results', {minus_only: true , focus: false} do
      task_factory.config(test_config_data_minus_2)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_minus_2,tasks)
      expect(match).to eql(true)
    end

  it '2 (-) operators, misplaced op range', {minus_only: true , focus: false} do
      task_factory.config(test_config_data_minus_3)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_minus_3,tasks)
      expect(match).to eql(true)
    end

   it '2 (-) operators, with negative/positive op range', {minus_only: true , focus: false} do
      task_factory.config(test_config_data_minus_4)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_minus_4,tasks)
      expect(match).to eql(58)
    end

   it '2 (-/+) mixed operators, with negative/positive op range', {mixed: true , focus: false} do
      task_factory.config(test_config_data_plus_minus_1)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_plus_minus_1,tasks)
      expect(match).to eql(248)
    end

   it '2 (*) operators, with negative/positive op range', {mixed: false , focus: false} do
      task_factory.config(test_config_data_mlp_1)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_mlp_1,tasks)
      expect(match).to eql(76)
    end

    it '2 (/) operators, with negative/positive op range', {mixed: false , focus: false} do
      task_factory.config(test_config_data_divmod_1)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_divmod_1,tasks)
      expect(match).to eql(63)
    end

    it '2 (*/) operators, with negative/positive op range', {mixed: true , focus: false} do
      task_factory.config(test_config_data_mlp_divmod_1)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_mlp_divmod_1,tasks)
      expect(match).to eql(234)
    end

    it '2 (+-*/) operators, with negative/positive op range', {mixed: true , focus: true} do
      task_factory.config(test_config_data_all_1)
      tasks = task_factory.tasks
      match = test_data_matcher(test_result_data_all_1,tasks)
      expect(match).to eql(234)
    end


  end

end
