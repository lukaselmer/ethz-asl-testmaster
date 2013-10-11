class Scenario < ActiveRecord::Base
  belongs_to :test_run

  validates :execution_multiplicity, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, if: -> (s) { s.test_run }

  scope :default_scenarios, -> () { where(test_run_id: nil) }
end
