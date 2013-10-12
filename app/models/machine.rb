class Machine < ActiveRecord::Base
  AWS_FIELDS = %i(ip_address owner_id launch_time instance_type instance_id dns_name status user_data availability_zone)

  TEST_STATES = [:unassociated, :idle, :testing, :log_collection]

  def set_aws_instance(aws_instance)
    @aws_instance = aws_instance
  end

  AWS_FIELDS.each do |field|
    define_method(field) do
      return '?' if @aws_instance.nil?
      @aws_instance.send(field)
    end
  end
end
