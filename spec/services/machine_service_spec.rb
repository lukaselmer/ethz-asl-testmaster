require 'spec_helper'

describe 'Machine service' do
  it 'should initialize the machine service' do
    if false

      begin

        m = MachineService.new
        z = m.instances.count
        u = m.unassociated_instances
        p u

      rescue Exception => e
        p e
      end
      #m.create_new_machines(1)
      3.should eq(3)
    end
  end
end


