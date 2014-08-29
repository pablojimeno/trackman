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

describe "Stopped for too long alarm" do

	before(:all) do
		Time.zone = "GMT"
		@car = Car.create!(numberplate: "44444")		
		@device = Device.create!(name: "Device", emei: "44444", car_id: @car.id)
		Traccar::Device.destroy_all
		@traccar_device = Traccar::Device.create(name: "Device", uniqueId: "44444")
  	end

  	describe "Alarm when vehicle stopped for more than X minutes" do 

  		before(:all) do 
  			rule = Rule.where(method_name: "stopped_for_more_than").first
			alarm = Alarm.create!(name: "Vehicle stopped for more than few 15 minutes in the last 12 hours")
			AlarmRule.create!(rule_id: rule.id, alarm_id: alarm.id, conjunction: nil, params: "{'threshold' => '15', 'scope'=>'720' }")
			@car.alarms << alarm
			State.destroy_all
  		end

  		it "should trigger alarm " do
  			# create states to simulate car stopped 
  			State.create(no_data: false, moving: true, car_id: @car.id, speed: 0.0, created_at: 60.minutes.ago)
	  		State.create(no_data: false, moving: false, car_id: @car.id, speed: 0.0, created_at: 45.minutes.ago)
	  		State.create(no_data: false, moving: false, car_id: @car.id, speed: 0.0, created_at: 30.minutes.ago)
	  		State.create(no_data: false, moving: true, car_id: @car.id, speed: 0.0, created_at: 15.minutes.ago)
			Rule.first.stopped_for_more_than(@car.id, { 'threshold' => '15', 'scope'=>'120' }).should equal(true)
  		end

  		it "shouldn't trigger alarm " do
  			# create states to simulate car stopped 
  			State.create(no_data: false, moving: false, car_id: @car.id, speed: 0.0, created_at: 50.minutes.ago)
	  		State.create(no_data: false, moving: false, car_id: @car.id, speed: 0.0, created_at: 45.minutes.ago)
	  		State.create(no_data: false, moving: true, car_id: @car.id, speed: 0.0, created_at: 30.minutes.ago)
	  		State.create(no_data: false, moving: true, car_id: @car.id, speed: 0.0, created_at: 15.minutes.ago)
			Rule.first.stopped_for_more_than(@car.id, { 'threshold' => '15', 'scope'=>'120' }).should equal(false)
  		end

	end


end
