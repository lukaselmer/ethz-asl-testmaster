class MachineService

  def initialize
    @ec2 = AWS.ec2
    @client = @ec2.client
    @server_id = ENV['SERVER_ID']
  end

  def resolve_instance_ip_address(id)
    @ec2.instances[id].ip_address
  end

  def my_instances
    machines_ordered_by_id.to_a.select { |i| i.user_data == @server_id && i.status != :terminated }
  end

  def consistency_check!
    m = my_instances
    if m.count != Machine.count
      msg = "Expected amazon instances count (#{m.count}) to be equal to the machine count (#{Machine.count})"
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
    raise "something might be wrong, should_count = #{should_count} (max 10 machines allowed)!" if should_count > 10
    sync_aws_instances
    has_count = Machine.count
    return if should_count <= has_count
    create_new_machines(should_count - has_count)
    sync_aws_instances
  end

  def start_db_instance
    i = @ec2.instances[ENV['MLMQ_DB_AWS_ID']]
    return if i.status == :running
    i.start
    sleep 0.5 until i.status == :running
  end

  def stop_all
    instances_to_stop = (my_instances << @ec2.instances[ENV['MLMQ_DB_AWS_ID']]).select{|i| i.status != :stopped}

    instances_to_stop.each do |i|
      puts "Stopping machine #{i.instance_id}"
      i.stop
    end

    my_instances.each do |i|
      sleep 0.5 until i.status == :stopped
      puts "Stopped machine #{i.instance_id}"
    end
  end

  def start_aws_instances(count)
    ids_to_start = Machine.order('instance_id asc').limit(count).to_a.map { |m| m.instance_id }
    instances_to_start = my_instances.select { |i| ids_to_start.include?(i.instance_id) && i.status != :running }
    return if instances_to_start.empty?

    instances_to_start.each do |i|
      puts "Starting machine #{i.instance_id}"
      i.start
    end

    instances_to_start.each do |i|
      sleep 0.5 until i.status == :running
      puts "Started machine #{i.instance_id}"
    end

    sleep 60
  end

  def sync_aws_instances
    Machine.all.each do |m|
      m.update_attribute :status, 'unknown'
    end
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
