class TestRunsController < ApplicationController
  before_action :set_test_run, only: [:show, :start, :stop, :download, :analyze, :edit, :clone, :archive, :update, :destroy]

  # GET /test_runs
  # GET /test_runs.json
  def index
    @test_runs = TestRun.all
    @test_runs = @test_runs.archived if params[:archived]
    @test_runs = @test_runs.unarchived if !params[:all] && !params[:archived]
  end

  def archive
    @test_run.archived_at = Time.now
    @test_run.save

    redirect_to test_runs_path, notice: 'Test run was archived successfully'
  end

  # GET /test_runs/1
  # GET /test_runs/1.json
  def show
    if params[:export]
      require 'csv'
      str = CSV.generate do |csv|
        @test_run.test_run_logs.each do |t|
          csv << [t.message_type, t.execution_in_microseconds, t.logged_at]
        end
      end
      send_data str, filename: "test_run_#{@test_run.id}.csv"
      return
    end

    if params[:type]
      @type = params[:type]
      @logs = @test_run.test_run_logs.where(message_type: @type)

      return

      @logs_graph = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: "Response Time for #{@type}")
        f.xAxis(categories: @logs.collect(&:logged_at))
        f.series(name: 'Response time in Microseconds', yAxis: 0, data: @logs.collect(&:execution_in_microseconds))

        f.yAxis [
                    {title: {text: 'Time in Microseconds', margin: 70}},
                ]

        f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical',)
        f.chart({defaultSeriesType: 'column'})
      end
    end
  end

  def analyze
    @types = init_types
    return if params[:other].blank?
    window_size = calc_window_size(params)
    params[:other][:startup_cooldown_time] = calc_startup_cooldown_time(params)
    send params[:other][:startup_cooldown_time]

    l = LogAnalyzerService.new
    file_path = l.analyze @test_run, params[:output_format], window_size, params[:other]

    send_file file_path unless file_path.nil?
  end

  #def start
  #  @test_run.start
  #  render :show
  #end

  #def stop
  #  @test_run.stop
  #  render :show
  #end

  def clone
    to_clone = @test_run
    @test_run = TestRun.new_with_test_run(to_clone)
    @test_run.name = to_clone.clone_name
    render :new
  end

  def download
    zipfile = @test_run.zip_logs
    send_file zipfile, filename: "test_run_#{@test_run.id}.zip"
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
  def calc_window_size(params)
    params[:window_size_minutes].to_i * 60 * 1000 +
        params[:window_size_seconds].to_i * 1000 +
        params[:window_size_milliseconds].to_i
  end

  def calc_startup_cooldown_time(params)
    params[:other][:startup_cooldown_time][:minutes].to_i * 60 * 1000 +
        params[:other][:startup_cooldown_time][:seconds].to_i * 1000 +
        params[:other][:startup_cooldown_time][:milliseconds].to_i
  end

  def init_types
    types = %w(CSndReq CSndReq#Error CSndReq#OK BDb BDb#dequeueMessage BDb#insertMessage BDb#peekMessage BDb#getPubQueues BRcvReq BSndResp BProcReq#QueuesWithPendingMessagesRequest BTotReqResp BDb#getClientId BDb#getQueueByClientId BDb#getPubQueues BDb#getNumMessages)

    "[#{types.collect { |t| "\"#{t}\"" }.join(',')}]"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_test_run
    @test_run = TestRun.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def test_run_params
    params.require(:test_run).permit(:name, :config, :autostart, scenarios_attributes:
        [:id, :name, :execution_multiplicity, :config_template,
         :execution_multiplicity_per_machine, :scenario_type, :_destroy])
  end

end
