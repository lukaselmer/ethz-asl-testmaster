class TestRun < ActiveRecord::Base
  has_many :test_run_logs
  has_many :scenarios

  validates :name, presence: true, uniqueness: true

  accepts_nested_attributes_for :scenarios, reject_if: :all_blank, allow_destroy: true

  default_scope { order('created_at desc') }

  scope :ready_to_start, -> { where(started_at: nil, autostart: true).reorder('id asc') }
  scope :archived, -> { where('archived_at is not null') }
  scope :unarchived, -> { where(archived_at: nil) }

  def self.new_with_default_scenarios
    new_with_scenarios(Scenario.default_scenarios.to_a)
  end

  def self.new_with_test_run(test_run_to_clone)
    new_with_scenarios(test_run_to_clone.scenarios.to_a)
  end

  def self.new_with_scenarios(scenarios_to_clone)
    test_run = new
    test_run.scenarios = scenarios_to_clone.map do |s|
      s = s.dup
      s.test_run = test_run
      s
    end
    test_run
  end

  def machines
    scenarios.includes(scenario_executions: [:machine]).map(&:scenario_executions).map(&:to_a).flatten.map(&:machine)
  end

  def clone_name
    regex = /clone (\d+)\z/
    match = regex.match(name)
    return "#{name} clone 1" unless match
    id = match[1].to_i

    name.gsub(regex, "clone #{id + 1}")
  end

  def started?
    !started_at.nil?
  end

  def stopped?
    !stopped_at.nil?
  end

  def ended?
    !ended_at.nil?
  end

  def running?
    state == :running
  end

  def state
    return :ended if ended?
    return :stopped if started? && stopped?
    return :running if started?
    :not_started
  end

  def start
    DeploymentService.new(self).start_test
  end

  def stop
    TestRunStopper.new(self).stop
  end

  def total_instances
    scenarios.to_a.sum(&:execution_multiplicity)
  end

  def zip_logs
    raise 'Logs not collected yet!' unless stopped? && ended?

    local_path_config = DeploymentService::LocalPathConfig.new(self)
    zip_status_file = local_path_config.zip_status_file
    zip_file = local_path_config.zip_file

    raise 'Zipping in progress!' if File.exist? zip_status_file
    return zip_file if File.exist? zip_file

    begin
      FileUtils.touch zip_status_file
      do_zip_logs local_path_config
    ensure
      File.delete zip_status_file
    end

    zip_file
  end

  def do_zip_logs(local_path_config)
    input_dir = local_path_config.collected_logs_path
    zip_file_name = local_path_config.zip_file

    require "#{Rails.root}/lib/zip_file_generator"

    ZipFileGenerator.new(input_dir, zip_file_name).write
  end

  def parse_additional_fields
    s = scenarios.first
    return '' if s.nil?

    %w(broker.workerthread.count broker.db.connectionpool.size).map do |k|
      t = s.config_template
      regex = /^#{k}\s*=\s*(\d*)/
      m = t.match regex
      next unless m
      "<span class=\"badge badge-success\">#{m[1]}</span> #{k}"
    end.compact.join(', ').html_safe
  end
end
