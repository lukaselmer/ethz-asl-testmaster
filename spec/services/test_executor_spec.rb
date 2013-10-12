require 'spec_helper'

describe 'Remote executor' do
  it 'should initialize the remote executor and start the remote' do
    if false
      pk = File.readlines('/Users/lukas/.ssh/id_rsa.pem')
      remote_machine = Machine.new(host: '54.229.62.65', private_key: pk, profile: 'broker')
      DeploymentService::RemoteExecutor.new(TestRun.new(id: 1), remote_machine).execute_test
    end
  end
end


