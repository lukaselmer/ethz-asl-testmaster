require 'spec_helper'

describe 'Deplyoment service' do
  it 'should initialize the depoyment service' do
    if false
      pk = File.readlines('/Users/lukas/.ssh/id_rsa.pem')
      test_machine = Machine.new(host: '54.229.62.65', private_key: pk, profile: 'broker')
      DeploymentService.new(TestRun.new(id: 1), test_machine).start_test
    end
  end
end


