class TestRun < ActiveRecord::Base
  has_many :test_run_logs
  has_many :scenarios

  validates :name, presence: true, uniqueness: true

  accepts_nested_attributes_for :scenarios, reject_if: :all_blank, allow_destroy: true

  def self.new_with_default_scenarios
    test_run = new
    test_run.scenarios = Scenario.default_scenarios.map do |s|
      s = s.dup
      s.test_run = test_run
      s
    end
    test_run
  end

  def state
    return :not_started if started_at.nil?
    return :running if ended_at.nil?
    :finished
  end

  def start
    # TODO
  end

  def stop
    # TODO
  end
end
