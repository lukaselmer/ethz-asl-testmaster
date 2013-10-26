class Machine < ActiveRecord::Base
  has_many :scenario_executions

  AWS_FIELDS = %i(ip_address owner_id launch_time instance_type instance_id dns_name status user_data availability_zone)

  TEST_STATES = [:idle, :testing, :log_collection]

  def self.create_by_aws_instance!(instance)
    create!(test_state: :idle, instance_id: instance.instance_id)
  end

  def sync_with_aws_instance(instance)
    AWS_FIELDS.each do |f|
      send("#{f}=", instance.send(f))
    end
    save!
  end

  #def set_aws_instance(aws_instance)
  #  @aws_instance = aws_instance
  #end

  #AWS_FIELDS.each do |field|
  #  define_method(field) do
  #    return nil if @aws_instance.nil?
  #    @aws_instance.send(field)
  #  end
  #end
end
