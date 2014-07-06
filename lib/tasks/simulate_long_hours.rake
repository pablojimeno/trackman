namespace :simulate do
  task :long_hours => :environment do
  	time = Time.now
  	20.times do 
  		state = State.create(no_data: false, moving: true, car_id: Car.first.id, created_at: time, updated_at: time , speed: 18, driver_id: User.first, device_id: Device.first)
  		state.save!
  		time = time - 30.minutes
  	end
  end
end