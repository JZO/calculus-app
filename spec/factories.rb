FactoryGirl.define do
  factory :task_roll, class: TaskRoll do
    name "JZOAKA"
    config {  { required_operators: [:+], max_operands: 1, mixed_operators: false, result_range: (5..10), operand_range: (0..10) } }

    initialize_with { new(name, config) }
  end
end
