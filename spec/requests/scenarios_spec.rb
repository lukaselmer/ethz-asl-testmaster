require 'spec_helper'

describe 'Scenarios' do

  before :each do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe 'GET /scenarios' do
    it 'works! (now write some real specs)' do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get scenarios_path
      response.status.should be(200)
    end
  end
end
