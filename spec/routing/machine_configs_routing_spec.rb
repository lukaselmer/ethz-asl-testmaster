require 'spec_helper'

describe MachineConfigsController do
  describe 'routing' do

    it 'routes to #index' do
      get('/machine_configs').should route_to('machine_configs#index')
    end

    it 'routes to #new' do
      get('/machine_configs/new').should route_to('machine_configs#new')
    end

    it 'routes to #show' do
      get('/machine_configs/1').should route_to('machine_configs#show', :id => '1')
    end

    it 'routes to #edit' do
      get('/machine_configs/1/edit').should route_to('machine_configs#edit', :id => '1')
    end

    it 'routes to #create' do
      post('/machine_configs').should route_to('machine_configs#create')
    end

    it 'routes to #update' do
      put('/machine_configs/1').should route_to('machine_configs#update', :id => '1')
    end

    it 'routes to #destroy' do
      delete('/machine_configs/1').should route_to('machine_configs#destroy', :id => '1')
    end

  end
end
