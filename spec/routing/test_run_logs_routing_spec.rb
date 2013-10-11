require 'spec_helper'

describe TestRunLogsController do
  describe 'routing' do

    it 'routes to #index' do
      get('/test_run_logs').should route_to('test_run_logs#index')
    end

    it 'routes to #new' do
      get('/test_run_logs/new').should route_to('test_run_logs#new')
    end

    it 'routes to #show' do
      get('/test_run_logs/1').should route_to('test_run_logs#show', :id => '1')
    end

    it 'routes to #edit' do
      get('/test_run_logs/1/edit').should route_to('test_run_logs#edit', :id => '1')
    end

    it 'routes to #create' do
      post('/test_run_logs').should route_to('test_run_logs#create')
    end

    it 'routes to #update' do
      put('/test_run_logs/1').should route_to('test_run_logs#update', :id => '1')
    end

    it 'routes to #destroy' do
      delete('/test_run_logs/1').should route_to('test_run_logs#destroy', :id => '1')
    end

  end
end
