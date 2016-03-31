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
    respond_to do |format|
      format.html
    end
  end

  def import
    if params[:file] != nil
      status = Device.import(params[:file])
      flash[status[:alert]] = status[:message]
      redirect_to device_manage_path
    else
      flash[:danger] = 'You need to upload at least one document (.xls / .csv / .xlsx)'
      redirect_to device_manage_path
    end
  end

  def manage
    @devices = Device.all
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
    @device = Device.new(device_params)

    if @device.valid?
      # device = Traccar::Device.create(name: device_params['name'], uniqueId: device_params['emei'])
      # device.users << Traccar::User.first

      if !simcard_params[:simcard_id].empty?
        simcard = Simcard.find(simcard_params[:simcard_id])
        simcard.update_attribute(:device_id, @device.id)
      end

      if @device.save
        redirect_to @device, notice: 'Device was successfully created.'
      else
        render :new
      end
    else
      render :new
    end
  end

  def update
    if @device.update(device_params)
      # if !simcard_params[:simcard_id].empty?
      #   simcard = Simcard.find(simcard_params[:simcard_id])
      #   simcard.update_attribute(:device_id, @device.id)
      # end
      redirect_to device_manage_path, notice: 'Device''s name was successfully updated.'
    else
      redirect_to device_manage_path
    end
  end

  def batch_destroy
    device_ids = params[:device_ids]
    device_ids.each do |device_id|
      @device = Device.find(device_id)
      traccar_user = Traccar::User.first
      traccar_device = Traccar::Device.where(uniqueId: @device.emei).first

      # remove join record
      if traccar_device.users.delete(traccar_user)
        traccar_device.positions.delete_all
        traccar_device.delete
        @device.destroy
      end
    end
    redirect_to devices_path
  end


  def destroy
    # get traccar:device using device's emei
    traccar_user = Traccar::User.first
    traccar_device = Traccar::Device.where(uniqueId: @device.emei).first

    # Remove join record
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
