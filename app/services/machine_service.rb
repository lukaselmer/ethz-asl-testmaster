class MachineService

  def initialize
    @ec2 = AWS.ec2
    @client = @ec2.client
  end

  #def unassociated_instances
  #  @ec2.instances.to_a.select { |i| i.user_data == 'unassociated' }
  #end

  #def associate
  #instances = unassociated_instances
  #return false if instances.empty?
  #
  #u = instances.first
  #
  #m = Machine.create!(test_state: :unassociated, instance_id: u.instance_id)
  #u.user_data = m.id
  #m.update_attribute :test_state, :idle
  #m
  #end

  def consistency_check!
    if instances.to_a.count != Machine.count
      raise Exception.new('instances.to_a.count != Machine.count')
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

  def start_test
  end

  def create_new_machine
    consistency_check!

    m = Machine.create!(test_state: :unassociated, instance_id: u.instance_id)

    options = {}
    options[:count] = 1
    options[:availability_zone] = 'eu-west-1a'
    options[:user_data] = m.id

    i = instances.create(options)
    m.update_attribute(:instance_id, i)

    i
  end
end
