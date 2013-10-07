class TestRunLogsController < ApplicationController
  before_action :set_test_run_log, only: [:show, :edit, :update, :destroy]

  # GET /test_run_logs
  # GET /test_run_logs.json
  def index
    @test_run_logs = TestRunLog.all
  end

  # GET /test_run_logs/1
  # GET /test_run_logs/1.json
  def show
  end

  # GET /test_run_logs/new
  def new
    @test_run_log = TestRunLog.new
  end

  # GET /test_run_logs/1/edit
  def edit
  end

  # POST /test_run_logs
  # POST /test_run_logs.json
  def create
    @test_run_log = TestRunLog.new(test_run_log_params)
    if @test_run_log.save
      redirect_to @test_run_log, notice: 'Test run log was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /test_run_logs/1
  # PATCH/PUT /test_run_logs/1.json
  def update
    if @test_run_log.update(test_run_log_params)
      redirect_to @test_run_log, notice: 'Test run log was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /test_run_logs/1
  # DELETE /test_run_logs/1.json
  def destroy
    @test_run_log.destroy
    redirect_to test_run_logs_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_test_run_log
    @test_run_log = TestRunLog.find(params[:id])
  end

# Never trust parameters from the scary internet, only allow the white list through.
  def test_run_log_params
    params.require(:test_run_log).permit(:logged_at, :message_type, :message_content, :execution_in_microseconds, :test_run_id, :test_machine_config_id)
  end

end
