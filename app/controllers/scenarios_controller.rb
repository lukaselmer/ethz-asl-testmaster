class ScenariosController < ApplicationController
  before_action :set_scenario, only: [:show, :edit, :update, :destroy]

  # GET /scenarios
  # GET /scenarios.json
  def index
    @scenarios = Scenario.default_scenarios
  end

  # GET /scenarios/1
  # GET /scenarios/1.json
  def show
  end

  # GET /scenarios/new
  def new
    @scenario = Scenario.new
  end

  # GET /scenarios/1/edit
  def edit
  end

  # POST /scenarios
  # POST /scenarios.json
  def create
    @scenario = Scenario.new(scenario_params)

    if @scenario.save
      redirect_to scenarios_path, notice: 'Scenario was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /scenarios/1
  # PATCH/PUT /scenarios/1.json
  def update
    if @scenario.update(scenario_params)
      redirect_to scenarios_path, notice: 'Scenario was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /scenarios/1
  # DELETE /scenarios/1.json
  def destroy
    @scenario.destroy
    redirect_to scenarios_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_scenario
    @scenario = Scenario.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scenario_params
    params.require(:scenario).permit(:name, :scenario_type, :execution_multiplicity, :execution_multiplicity_per_machine, :config_template, :test_run_id)
  end
end
