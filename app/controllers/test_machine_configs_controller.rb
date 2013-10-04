class TestMachineConfigsController < ApplicationController
  before_action :set_test_machine_config, only: [:show, :edit, :update, :destroy]

  # GET /test_machine_configs
  # GET /test_machine_configs.json
  def index
    @test_machine_configs = TestMachineConfig.all
  end

  # GET /test_machine_configs/1
  # GET /test_machine_configs/1.json
  def show
  end

  # GET /test_machine_configs/new
  def new
    @test_machine_config = TestMachineConfig.new
  end

  # GET /test_machine_configs/1/edit
  def edit
  end

  # POST /test_machine_configs
  # POST /test_machine_configs.json
  def create
    @test_machine_config = TestMachineConfig.new(test_machine_config_params)

    respond_to do |format|
      if @test_machine_config.save
        format.html { redirect_to @test_machine_config, notice: 'Test machine config was successfully created.' }
        format.json { render action: 'show', status: :created, location: @test_machine_config }
      else
        format.html { render action: 'new' }
        format.json { render json: @test_machine_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /test_machine_configs/1
  # PATCH/PUT /test_machine_configs/1.json
  def update
    respond_to do |format|
      if @test_machine_config.update(test_machine_config_params)
        format.html { redirect_to @test_machine_config, notice: 'Test machine config was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @test_machine_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_machine_configs/1
  # DELETE /test_machine_configs/1.json
  def destroy
    @test_machine_config.destroy
    respond_to do |format|
      format.html { redirect_to test_machine_configs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_machine_config
      @test_machine_config = TestMachineConfig.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_machine_config_params
      params.require(:test_machine_config).permit(:name, :command_line_arguments, :test_run_id)
    end
end
