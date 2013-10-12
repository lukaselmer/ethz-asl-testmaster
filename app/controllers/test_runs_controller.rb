class TestRunsController < ApplicationController
  before_action :set_test_run, only: [:show, :start, :stop, :edit, :update, :destroy]

  # GET /test_runs
  # GET /test_runs.json
  def index
    @test_runs = TestRun.all
  end

  # GET /test_runs/1
  # GET /test_runs/1.json
  def show
  end

  def start
    @test_run.start
    render :show
  end

  def stop
    @test_run.stop
    render :show
  end

  # GET /test_runs/new
  def new
    redirect_to scenarios_path, alert: 'Create some scenarios first' and return if Scenario.default_scenarios.empty?
    @test_run = TestRun.new_with_default_scenarios
  end

  # GET /test_runs/1/edit
  def edit
  end

  # POST /test_runs
  # POST /test_runs.json
  def create
    @test_run = TestRun.new(test_run_params)
    @test_run.scenarios.map! { |s| s.test_run = @test_run; s }

    if @test_run.save
      redirect_to @test_run, notice: 'Test run was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /test_runs/1
  # PATCH/PUT /test_runs/1.json
  def update
    if @test_run.update(test_run_params)
      redirect_to @test_run, notice: 'Test run was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /test_runs/1
  # DELETE /test_runs/1.json
  def destroy
    @test_run.destroy
    redirect_to test_runs_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_test_run
    @test_run = TestRun.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def test_run_params
    params.require(:test_run).permit(:name, :config, scenarios_attributes: [:id, :name, :execution_multiplicity, :config_template, :_destroy])
  end

end
