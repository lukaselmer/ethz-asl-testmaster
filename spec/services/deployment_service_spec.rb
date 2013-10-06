require 'spec_helper'

describe 'Deplyoment service' do
  it 'should initialize the depoyment service' do
    pk = File.readlines('/Users/lukas/.ssh/id_rsa.pem')
    DeploymentService.new(TestRun.new(id: 1), Machine.new('54.229.62.65', pk, 'broker')).start_test
  end
end


