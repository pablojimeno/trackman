# == Schema Information
#
# Table name: rules
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  method_name :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe "Speed limit" do

	before(:all) do
		Time.zone = "GMT"
		@car = FactoryGirl.create(:car, numberplate: "123")	
		@device = FactoryGirl.create(:device, name: "Device", emei: @car.numberplate, car_id: @car.id)
		Traccar::Device.destroy_all
		@traccar_device = Traccar::Device.create(name: @device.name, uniqueId: @device.emei)
		@rule = Rule.where(method_name: "speed_limit").first
		alarm = FactoryGirl.create(:alarm, name: "Vehicle is going faster than 60 km/h")
		AlarmRule.create!(rule_id: @rule.id, alarm_id: alarm.id, conjunction: nil, params: "{'speed'=> '60.0'}")
		@car.alarms << alarm
		Traccar::Position.destroy_all
  	end

  	after(:all) do
  		Device.destroy_all
  	end

  	it "should trigger alarm when speed > X km/h" do 	
		@traccar_device.positions << Traccar::Position.create(altitude: 0.0, course: 0.0, latitude: 48.856614, longitude: 2.352222, other: "<info><protocol>t55</protocol><battery>24</battery...", power: nil, speed: 70.0, time: Time.zone.now, valid: true, device_id: @traccar_device.id)
		@rule.speed_limit(@car.id, { "speed" => 60 }).should equal(true)
		@traccar_device.positions << Traccar::Position.create(altitude: 0.0, course: 0.0, latitude: 48.856614, longitude: 2.352222, other: "<info><protocol>t55</protocol><battery>24</battery...", power: nil, speed: 50.0, time: Time.zone.now, valid: true, device_id: @traccar_device.id)
		@rule.speed_limit(@car.id, { "speed" => 60 }).should equal(false)
	end	

	it "shouldn't trigger alarm when no data received from vehicle" do
		@rule.speed_limit(@car.id, { "speed" => 60 }).should equal(false)
	end

	it "shouldn't trigger alarm when vehicle not moving" do
		State.destroy_all
		@traccar_device.positions << Traccar::Position.create(altitude: 0.0, course: 0.0, latitude: 48.856614, longitude: 2.352222, other: "<info><protocol>t55</protocol><battery>24</battery...", power: nil, speed: 1.0, time: Time.zone.now, valid: true, device_id: @traccar_device.id)
		@traccar_device.positions << Traccar::Position.create(altitude: 0.0, course: 0.0, latitude: 48.856614, longitude: 2.352222, other: "<info><protocol>t55</protocol><battery>24</battery...", power: nil, speed: 1.0, time: Time.zone.now, valid: true, device_id: @traccar_device.id)
 		@rule.speed_limit(@car.id, { "speed" => 60 }).should equal(false)
	end

	it "shouldn't trigger alarm if speed < 60 km/h" do 
		@traccar_device.positions << Traccar::Position.create(altitude: 0.0, course: 0.0, latitude: 48.856614, longitude: 2.352222, other: "<info><protocol>t55</protocol><battery>24</battery...", power: nil, speed: 50.0, time: Time.zone.now, valid: true, device_id: @traccar_device.id)
		@rule.speed_limit(@car.id, { "speed" => 60 }).should equal(false)
	end

	

end
