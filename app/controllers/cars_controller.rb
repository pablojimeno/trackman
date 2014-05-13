class CarsController < ApplicationController
  before_action :set_car, only: [:show, :edit, :update, :destroy]
  #load_and_authorize_resource

  has_scope :by_car_model
  has_scope :by_car_type
  has_scope :trackable do |controller, scope, value|
    if value == "all"
      scope
    elsif value == "true"
      scope.traceable
    elsif value == "false"
      scope.untraceable
    end 
  end

  def index
    @cars = apply_scopes(Car).all
  end

  # GET /cars/1
  # GET /cars/1.json
  def show
    @position = Car.find(params[:id]).last_position
    @collection =  [@position]
    @hash = Gmaps4rails.build_markers(@collection) do |position, marker|
      marker.lat position[:latitude].to_s
      marker.lng position[:longitude].to_s
    end
  end

  # GET /cars/new
  def new
    @car = Car.new
  end

  # GET /cars/1/edit
  def edit
    @device = Device.where(:car_id => params[:id])
  end

  # POST /cars
  # POST /cars.json
  def create
    @car = Car.new(car_params)
    if @car.save
      redirect_to @car, notice: 'Car was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /cars/1
  # PATCH/PUT /cars/1.json
  def update
    respond_to do |format|
      if @car.update(car_params)
        if device_params.has_key?('device_id') && !device_params['device_id'].empty?
          # release other device 
          if @car.has_device?
            @car.device.update_attribute(:car_id, nil)
          end
          # attach new device 
          device = Device.find(device_params['device_id'])
          device.update_attribute(:car_id, @car.id)
        end

        format.html { redirect_to @car, notice: 'Car was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cars/1
  # DELETE /cars/1.json
  def destroy
    @car.destroy
    respond_to do |format|
      format.html { redirect_to cars_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_car
      @car = Car.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def car_params
      params.require(:car).permit(:mileage, :numberplate, :car_model_id, :car_type_id, :registration_no, :year, :color, :group_id, :user_id)
    end

    def device_params
      params.permit(:device_id)
    end
end