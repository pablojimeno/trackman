# This will go over each device in the Traccar database and generate positions 
# so it would look like the car using this device is idle
namespace :simulate do
  task :idle_cars => :environment do
  	Traccar::Device.all.each do |device|
  		if device.last_position.count == 0	
        puts "device.last_position.count == 0"	
        # generate the first position for this device
        new_position = Traccar::Position.create(altitude: 0.0, course: 0.0, latitude: 48.85837, longitude: 2.294481, other: "<info><protocol>t55</protocol><battery>24</battery...", power: nil, speed: 0.0, time: Time.now, valid: true, device_id: device.id)
        device.positions << new_position
  		else 	
        random_choice = [0, 1].sample
        if false #random_choice == 0 
          puts "random_choice == 0"
          # generate a position to make the car seem like it's moving 
          old_position = device.last_position
          new_latitude = old_position[:latitude] + 0.001
          new_longitude = old_position[:longitude] + 0.001
          new_position = Traccar::Position.create(course: 0.0, latitude: new_latitude, longitude: new_longitude, other: "<info><protocol>t55</protocol><battery>24</battery...", power: nil, speed: 0.0, time: Time.now, valid: true, device_id: device.id)
          device.positions << new_position
        elsif true #random_choice == 1
          puts "random_choice == 1"
          # generate a position to make the car seem like it's not moving 
          new_position = Traccar::Position.create(altitude: 0.0, course: 0.0, latitude: device.last_position[:latitude], longitude: device.last_position[:longitude], other: "<info><protocol>t55</protocol><battery>24</battery...", power: nil, speed: 0.0, time: Time.now, valid: true, device_id: device.id)
          device.positions << new_position
        end		
        
  		end
  	end
  end
end