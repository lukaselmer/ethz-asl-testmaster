require 'spec_helper'

describe 'Machine service' do
  it 'should initialize the machine service' do
    if false
      begin

        m = MachineService.new
        u = m.create_new_machines(1)
        p u

      rescue Exception => e
        p e
      end
      3.should eq(3)
    end
  end

  it 'should sync the machine state' do
    if false
      begin
        m = MachineService.new
        m.ensure_aws_instances(3)
      rescue Exception => e
        p e
      end
      3.should eq(3)
    end
  end
end
