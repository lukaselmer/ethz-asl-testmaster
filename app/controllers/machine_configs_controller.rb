class MachineConfigsController < ApplicationController
  before_action :set_machine_config, only: [:show, :edit, :update, :destroy]

  # GET /machine_configs
  # GET /machine_configs.json
  def index
    @machine_configs = MachineConfig.all
  end

  # GET /machine_configs/1
  # GET /machine_configs/1.json
  def show
  end

  # GET /machine_configs/new
  def new
    @machine_config = MachineConfig.new
  end

  # GET /machine_configs/1/edit
  def edit
  end

  # POST /machine_configs
  # POST /machine_configs.json
  def create
    @machine_config = MachineConfig.new(machine_config_params)

    respond_to do |format|
      if @machine_config.save
        format.html { redirect_to @machine_config, notice: 'Machine config was successfully created.' }
        format.json { render action: 'show', status: :created, location: @machine_config }
      else
        format.html { render action: 'new' }
        format.json { render json: @machine_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /machine_configs/1
  # PATCH/PUT /machine_configs/1.json
  def update
    if @machine_config.update(machine_config_params)
      redirect_to @machine_config, notice: 'Machine config was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /machine_configs/1
  # DELETE /machine_configs/1.json
  def destroy
    @machine_config.destroy
    respond_to do |format|
      format.html { redirect_to machine_configs_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_machine_config
    @machine_config = MachineConfig.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def machine_config_params
    params.require(:machine_config).permit(:name, :template)
  end

end
