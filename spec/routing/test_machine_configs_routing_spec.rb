require "spec_helper"

describe TestMachineConfigsController do
  describe "routing" do

    it "routes to #index" do
      get("/test_machine_configs").should route_to("test_machine_configs#index")
    end

    it "routes to #new" do
      get("/test_machine_configs/new").should route_to("test_machine_configs#new")
    end

    it "routes to #show" do
      get("/test_machine_configs/1").should route_to("test_machine_configs#show", :id => "1")
    end

    it "routes to #edit" do
      get("/test_machine_configs/1/edit").should route_to("test_machine_configs#edit", :id => "1")
    end

    it "routes to #create" do
      post("/test_machine_configs").should route_to("test_machine_configs#create")
    end

    it "routes to #update" do
      put("/test_machine_configs/1").should route_to("test_machine_configs#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/test_machine_configs/1").should route_to("test_machine_configs#destroy", :id => "1")
    end

  end
end
