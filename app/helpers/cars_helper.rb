module CarsHelper

	########## 
	# devices helpers
	########## 
	def no_available_devices?
		if Device.available_devices.count == 0 
			return true
		else 
			return false
		end
	end

	def list_available_devices
		return select_tag('device_id', content_tag(:option,'Select Device ...', :value=>"")+options_from_collection_for_select(Device.available_devices, 'id', 'name'), class: "form-control")
	end

	def list_no_available_devices
		return select_tag('device_id', content_tag(:option,'No available devices', :value=>""), class: "form-control")
	end

	def list_devices_with_default(device)
		return select_tag('device_id', content_tag(:option, device.name, :value=> device.id )+content_tag(:option,'Detach device', :value=>"")+options_from_collection_for_select(Device.available_devices, 'id', 'name'), class: "form-control")
	end

	########## 
	# drivers helpers
	########## 
	def no_available_drivers?
		if User.available_drivers.count == 0 
			return true
		else 
			return false
		end
	end

	def list_available_drivers
		return select_tag('user_id', content_tag(:option,'Select Driver ...', :value=>"")+options_from_collection_for_select(User.available_drivers, 'id', 'name_with_email'), class: "form-control")
	end

	def list_no_available_drivers
		return select_tag('user_id', content_tag(:option,'No available drivers', :value=>""), class: "form-control")
	end

	def list_drivers_with_default(driver)
		return select_tag('user_id', content_tag(:option, driver.name, :value=> driver.id )+options_from_collection_for_select(User.available_drivers, 'id', 'name_with_email'), class: "form-control")
	end

	########## 
	# rules/alarms helpers
	##########

	def render_movement_status(car)
		if car.has_device? && car.moving?
			return "Car is moving"
		elsif car.has_device?
			return "Car isn't moving"
		else	
			return "No GPS Data"
		end
	end


	# cars#index
	def checked_radio_button(value, row)
		if value == row
			return true
		else
			return false
		end
	end

	def pretty_time(created_at, default_value = "")
		if created_at.nil?
			return default_value
		else
			return "#{created_at.hour}:#{created_at.min}:#{created_at.sec}"
		end
	end

	def pretty_date(created_at, default_value = "")
		if created_at.nil?
			return default_value
		else
			return "#{created_at.day}/#{created_at.month}/#{created_at.year}"
		end
	end

end
