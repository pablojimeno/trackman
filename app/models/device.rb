# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  emei            :string(255)
#  cost_price      :float
#  created_at      :datetime
#  updated_at      :datetime
#  device_model_id :integer
#  device_type_id  :integer
#  car_id          :integer
#  company_id      :integer
#  movement        :boolean
#  last_checked    :datetime
#

class Device < ActiveRecord::Base
	include ActionView::Helpers::DateHelper

	scope :by_device_model, -> device_model_id { where(:device_model_id => device_model_id) }
	scope :by_device_type, -> device_type_id { where(:device_type_id => device_type_id) }

	scope :with_simcard, -> { where("id IN (SELECT device_id FROM Simcards WHERE device_id IS NOT NULL)") }
	scope :without_simcard, -> { where("id NOT IN (SELECT device_id FROM Simcards WHERE device_id IS NOT NULL)") }
	
	scope :available, -> { where(:car_id => nil) }
	scope :used, -> { where("car_id IS NOT NULL") }

	acts_as_tenant(:company)

	has_one :simcard
	belongs_to :device_model 
	belongs_to :device_type
	belongs_to :car
	belongs_to :company


	def self.available_devices
		Device.where(:car_id => nil)
	end

	def self.devices_without_simcards(device_id)
		if device_id.nil?
			Device.where("id NOT IN (SELECT device_id FROM Simcards WHERE device_id IS NOT NULL)")
		else
			Device.where("id NOT IN (SELECT device_id FROM Simcards WHERE device_id IS NOT NULL) OR id = #{device_id}")
		end
	end

	def traccar_device
		Traccar::Device.where(uniqueId: self.emei).first
	end

	def has_car?
		!self.car_id.nil?
	end

	def has_simcard? 
		!self.simcard.nil?
	end

	def last_position
		device = Traccar::Device.where(uniqueId: self.emei).first
		if device.nil?
			return Hash.new
		else
			Traccar::Device.where(uniqueId: self.emei).first.last_position
		end
	end

	def last_positions(number=2)
		traccar_device = Traccar::Device.where(:uniqueId => self.emei).first
		return traccar_device.last_positions(number)
	end

	# check if the device is reporting that the car is moving (or not)
	def moving?(precision = 0.0001)
		last_positions = self.last_positions(2).to_a
		if last_positions.count == 2
			latitude1 = last_positions[0].latitude 
			longitude1 = last_positions[0].longitude
			latitude2 = last_positions[1].latitude
			longitude2 = last_positions[1].longitude

			threshold = precision
			if (latitude1 - latitude2).abs < threshold && (longitude1 - longitude2).abs < threshold
				self.update_attributes(:movement => false, :last_checked => DateTime.now)
				return false
			else 
				self.update_attributes(:movement => true, :last_checked => DateTime.now)
				return true
			end 
		else
			return false
		end
	end

	def no_data?
		last_position = self.traccar_device.positions.last

		seconds = Time.now.utc - last_position.time.utc

		#return "#{time_ago_in_words(last_position.time)} ago OR #{since} seconds"

		if seconds >= 20.minutes
			return true
		else
			return false
		end
	end
	
	# return the speed of the vehicle associated with the last position
	def speed
		self.traccar_device.positions.last.speed
	end

	

	def stolen?
		# check if the engine off (but the car is still moving)
	end

	def long_hours?
		# check when was the last pause 
		# 	(let's say a pause is 15 minutes for now)
	end

	def long_pause? 
		# check when was the last the vehicle was moving 
		# 	(that way we can deduce the duration of the current pause and decide if it's too long or not)
	end

	
	
end
