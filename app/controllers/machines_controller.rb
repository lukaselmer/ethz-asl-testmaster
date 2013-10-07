class MachinesController < ApplicationController
  before_action :set_machine, only: [:show, :edit, :update, :destroy]

  # GET /machines
  # GET /machines.json
  def index
    @machines = Machine.all
  end

  # GET /machines/1
  # GET /machines/1.json
  def show
  end

  # GET /machines/new
  def new
    @machine = Machine.new
  end

  # GET /machines/1/edit
  def edit
  end

  # POST /machines
  # POST /machines.json
  def create
    @machine = Machine.new(machine_params)

    if @machine.save
      redirect_to @machine, notice: 'Machine was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /machines/1
  # PATCH/PUT /machines/1.json
  def update
    if @machine.update(machine_params)
      redirect_to @machine, notice: 'Machine was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /machines/1
  # DELETE /machines/1.json
  def destroy
    @machine.destroy
    redirect_to machines_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_machine
    @machine = Machine.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def machine_params
    params.require(:machine).permit(:host, :profile, :state, :private_key, :additional_info)
  end
end
