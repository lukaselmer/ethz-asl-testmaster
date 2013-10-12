require 'spec_helper'

describe 'Deplyoment service' do
  it 'should initialize the depoyment service' do
    DeploymentService.new(TestRun.new(id: 1)).start_test
  end
end


