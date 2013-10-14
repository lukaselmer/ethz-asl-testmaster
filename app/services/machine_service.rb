class MachineService

  def initialize
    @ec2 = AWS.ec2
    @client = @ec2.client
    @server_id = ENV['SERVER_ID']
  end

  def my_instances
    @ec2.instances.to_a.select { |i| i.user_data == @server_id && i.status != :terminated }
  end

  def consistency_check!
    m = my_instances
    if my_instances.count != Machine.count
      msg = "Expected amazon instances count (#{my_instances.count}) to be equal to the machine count (#{Machine.count})"
      raise Exception.new(msg)
    end
  end

  def instances
    @ec2.instances
  end

  def machines_ordered_by_id
    instances.sort_by(&:id)
  end

  def actions
    %i(reboot start stop)
  end

  def ensure_aws_instances(should_count)
    raise "something might be wrong, should_count = #{should_count}!" if should_count > 10
    sync_aws_instances
    has_count = Machine.count
    return if should_count <= has_count
    create_new_machines(should_count - has_count)
  end

  def sync_aws_instances
    instances = my_instances
    instances.each do |i|
      m = Machine.where(instance_id: i.instance_id).first
      m = Machine.create_by_aws_instance!(i) if m.nil?
      m.sync_with_aws_instance(i)
    end
  end

  def create_new_machines(count)
    consistency_check!

    options = {}
    options[:count] = count
    options[:availability_zone] = ENV['AWS_ZONE']
    options[:user_data] = @server_id
    options[:instance_type] = 't1.micro'
    #options[:subnet] = 'vpc-e440528f'
    options[:image_id] = 'ami-843ed8f3'
    options[:security_group_ids] = ['sg-e316e28c']
    # options[:key_name] = ''

    new_instances = instances.create(options)
    new_instances = [new_instances] if count == 1
    new_machines = new_instances.to_a.collect do |instance|
      Machine.create_by_aws_instance!(instance)
    end
    sync_aws_instances
    new_machines
  end
end
