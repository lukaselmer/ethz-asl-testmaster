class Scenario < ActiveRecord::Base
  belongs_to :test_run
  has_many :scenario_executions

  validates :execution_multiplicity, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, if: -> (s) { s.test_run }
  validates :execution_multiplicity_per_machine, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 500 }, if: -> (s) { s.test_run }
  validates :name, :scenario_type, presence: true
  validates :scenario_type, presence: true, inclusion: %w(client broker)

  scope :default_scenarios, -> () { where(test_run_id: nil) }
  
  default_scope { order('name asc') }
end
