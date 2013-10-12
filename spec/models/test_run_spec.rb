require 'spec_helper'

describe TestRun do

  describe 'states' do
    it 'is started when test started_at is set' do
      test_run = TestRun.new
      test_run.started?.should be_false
      test_run.started_at = DateTime.new
      test_run.started?.should be_true
    end

    it 'is ended when test ended_at is set' do
      test_run = TestRun.new
      test_run.ended?.should be_false
      test_run.ended_at = DateTime.new
      test_run.ended?.should be_true
    end

    it 'returns the correct state' do
      test_run = TestRun.new
      test_run.state.should eq(:not_started)
      test_run.started_at = DateTime.new
      test_run.state.should eq(:running)
      test_run.ended_at = DateTime.new
      test_run.state.should eq(:ended)
    end
  end
end
