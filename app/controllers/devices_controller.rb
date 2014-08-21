class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  has_scope :by_device_model
  has_scope :by_device_type
  has_scope :has_simcard do |controller, scope, value|
    if value == "all"
      scope
    elsif value == "true"
      scope.with_simcard
    elsif value == "false"
      scope.without_simcard
    end 
  end

  has_scope :available do |controller, scope, value|
    if value == "all"
      scope
    elsif value == "true"
      scope.available
    elsif value == "false"
      scope.used
    end 
  end



  def index
    @q = apply_scopes(Device).all.search(params[:q])
    @devices = @q.result(distinct: true)
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  # POST /devices.json
  def create
    render text: simcard_params[:simcard_id]
    return 

    @device = Device.new(device_params)
    #create the device in Traccar db
    device = Traccar::Device.create(name: device_params['name'], uniqueId: device_params['emei'])
    # attach the newly created device to the admin user of the traccar db
    device.users << Traccar::User.first

    if !simcard_params[:simcard_id].empty?
      simcard = Simcard.find(simcard_params[:simcard_id])
    end

    if @device.save
      redirect_to @device, notice: 'Device was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    if @device.update(device_params)
      redirect_to @device, notice: 'Device was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    # get traccar:device using device's emei
    traccar_user = Traccar::User.first
    traccar_device = Traccar::Device.where(uniqueId: @device.emei).first
    
    # remove join record 
    if traccar_device.users.delete(traccar_user)
      traccar_device.positions.delete_all
      traccar_device.delete
      @device.destroy
      redirect_to devices_url, notice: 'Device was successfully destroyed.'
    else
      redirect_to @device, notice: "Device couldn't be destroyed."
    end

    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    def simcard_params
      params.permit(:simcard_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:name, :emei, :cost_price, :car_id, :device_model_id, :device_type_id)
    end
end
