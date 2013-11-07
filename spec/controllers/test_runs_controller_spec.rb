require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe TestRunsController do

  before :each do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # TestRun. As you add validations to TestRun, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {'name' => 'MyString'} }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TestRunsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET index' do
    it 'assigns all test_runs as @test_runs' do
      test_run = TestRun.create! valid_attributes
      get :index, {}, valid_session
      assigns(:test_runs).should eq([test_run])
    end
  end

  describe 'GET show' do
    it 'assigns the requested test_run as @test_run' do
      test_run = TestRun.create! valid_attributes
      get :show, {id: test_run.to_param}, valid_session
      assigns(:test_run).should eq(test_run)
    end
  end

  describe 'GET start' do
    it 'assigns the requested test_run as @test_run' do
      #test_run = TestRun.create! valid_attributes
      #TestRun.any_instance.should_receive(:start)
      #get :start, {id: test_run.to_param}, valid_session
      #assigns(:test_run).should eq(test_run)
    end
  end

  describe 'GET stop' do
    it 'assigns the requested test_run as @test_run' do
      #test_run = TestRun.create! valid_attributes
      #TestRun.any_instance.should_receive(:stop)
      #get :stop, {id: test_run.to_param}, valid_session
      #assigns(:test_run).should eq(test_run)
    end
  end

  describe 'GET analyze' do
    it 'assigns the requested test_run as @test_run' do
      test_run = TestRun.create! valid_attributes
      LogAnalyzerService.any_instance.should_receive(:analyze)
      get :analyze, {id: test_run.to_param}, valid_session
      assigns(:test_run).should eq(test_run)
    end
  end

  describe 'GET new' do
    it 'assigns a new test_run as @test_run' do
      Scenario.create!(name: 'test')
      get :new, {}, valid_session
      assigns(:test_run).should be_a_new(TestRun)
    end

    it 'redirects if no scenarios are availible' do
      get :new, {}, valid_session
      response.should redirect_to(scenarios_path)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested test_run as @test_run' do
      test_run = TestRun.create! valid_attributes
      get :edit, {id: test_run.to_param}, valid_session
      assigns(:test_run).should eq(test_run)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new TestRun' do
        expect {
          post :create, {test_run: valid_attributes}, valid_session
        }.to change(TestRun, :count).by(1)
      end

      it 'assigns a newly created test_run as @test_run' do
        post :create, {test_run: valid_attributes}, valid_session
        assigns(:test_run).should be_a(TestRun)
        assigns(:test_run).should be_persisted
      end

      it 'redirects to the created test_run' do
        post :create, {test_run: valid_attributes}, valid_session
        response.should redirect_to(TestRun.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved test_run as @test_run' do
        # Trigger the behavior that occurs when invalid params are submitted
        TestRun.any_instance.stub(:save).and_return(false)
        post :create, {test_run: {'name' => 'invalid value'}}, valid_session
        assigns(:test_run).should be_a_new(TestRun)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TestRun.any_instance.stub(:save).and_return(false)
        post :create, {test_run: {'name' => 'invalid value'}}, valid_session
        response.should render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested test_run' do
        test_run = TestRun.create! valid_attributes
        # Assuming there are no other test_runs in the database, this
        # specifies that the TestRun created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TestRun.any_instance.should_receive(:update).with({'name' => 'MyString'})
        put :update, {id: test_run.to_param, test_run: {'name' => 'MyString'}}, valid_session
      end

      it 'assigns the requested test_run as @test_run' do
        test_run = TestRun.create! valid_attributes
        put :update, {id: test_run.to_param, test_run: valid_attributes}, valid_session
        assigns(:test_run).should eq(test_run)
      end

      it 'redirects to the test_run' do
        test_run = TestRun.create! valid_attributes
        put :update, {id: test_run.to_param, test_run: valid_attributes}, valid_session
        response.should redirect_to(test_run)
      end
    end

    describe 'with invalid params' do
      it 'assigns the test_run as @test_run' do
        test_run = TestRun.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TestRun.any_instance.stub(:save).and_return(false)
        put :update, {id: test_run.to_param, test_run: {'name' => 'invalid value'}}, valid_session
        assigns(:test_run).should eq(test_run)
      end

      it "re-renders the 'edit' template" do
        test_run = TestRun.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TestRun.any_instance.stub(:save).and_return(false)
        put :update, {id: test_run.to_param, test_run: {'name' => 'invalid value'}}, valid_session
        response.should render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested test_run' do
      test_run = TestRun.create! valid_attributes
      expect {
        delete :destroy, {id: test_run.to_param}, valid_session
      }.to change(TestRun, :count).by(-1)
    end

    it 'redirects to the test_runs list' do
      test_run = TestRun.create! valid_attributes
      delete :destroy, {id: test_run.to_param}, valid_session
      response.should redirect_to(test_runs_url)
    end
  end

end
