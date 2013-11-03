class Machine < ActiveRecord::Base
  has_many :scenario_executions

  AWS_FIELDS = %i(ip_address owner_id launch_time instance_type instance_id dns_name status user_data availability_zone)

  TEST_STATES = [:idle, :testing, :log_collection]

  scope :ready, -> { where(status: :running) }

  def self.create_by_aws_instance!(instance)
    create!(test_state: :idle, instance_id: instance.instance_id)
  end

  def sync_with_aws_instance(instance)
    raise 'Cannot change instance id once set!' if (!instance_id.blank? && instance.instance_id != instance_id)

    AWS_FIELDS.each do |f|
      send("#{f}=", instance.send(f))
    end
    save!
  end
end
