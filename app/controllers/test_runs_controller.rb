class TestRunsController < ApplicationController
  before_action :set_test_run, only: [:show, :edit, :update, :destroy]

  # GET /test_runs
  # GET /test_runs.json
  def index
    @test_runs = TestRun.all
  end

  # GET /test_runs/1
  # GET /test_runs/1.json
  def show
  end

  # GET /test_runs/new
  def new
    @test_run = TestRun.new
  end

  # GET /test_runs/1/edit
  def edit
  end

  # POST /test_runs
  # POST /test_runs.json
  def create
    @test_run = TestRun.new(test_run_params)

    respond_to do |format|
      if @test_run.save
        format.html { redirect_to @test_run, notice: 'Test run was successfully created.' }
        format.json { render action: 'show', status: :created, location: @test_run }
      else
        format.html { render action: 'new' }
        format.json { render json: @test_run.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /test_runs/1
  # PATCH/PUT /test_runs/1.json
  def update
    respond_to do |format|
      if @test_run.update(test_run_params)
        format.html { redirect_to @test_run, notice: 'Test run was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @test_run.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_runs/1
  # DELETE /test_runs/1.json
  def destroy
    @test_run.destroy
    respond_to do |format|
      format.html { redirect_to test_runs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_run
      @test_run = TestRun.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_run_params
      params.require(:test_run).permit(:state)
    end
end
