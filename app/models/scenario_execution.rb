class ScenarioExecution < ActiveRecord::Base
  include DeploymentService::Downloader

  belongs_to :scenario
  belongs_to :machine

  has_many :scenario_execution_jvms

  def config_folder
    "#{scenario.id}_#{machine.id}"
  end

  def exec_ids
    (0..(scenario.execution_multiplicity_per_machine - 1)).to_a
  end
end
