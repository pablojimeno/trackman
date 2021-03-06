class ImportAllLeftsCodeWorker
	include Sidekiq::Worker

	def perform
    last_position_id = ImportStatus.where.not(position_id: nil).last

    position = 
      if last_position_id
        Traccar::Position.where("id > ?", last_position_id.position_id)
      else
        Traccar::Position.all
      end

    positions = position.present? ? position : Traccar::Position.all

    positions.each do |position|
	    unless ImportStatus.where(position_id: position.try(:id)).present?
	      ImportStatus.create(position_id: position.try(:id))

	      lat = position.latitude
	      lon = position.longitude
	      device_id = position.deviceid
	      unique_id = position.device.uniqueid
	      position_id = position.try(:id)
	      fix_time = position.fixtime
	      valid = position.valid
	      speed = position.speed # Speed in Knots
	      status = position.course
	      device = Device.find_by_emei(unique_id)
	      position   = Traccar::Position.find position_id
	      jsoned_xml = JSON.parse(position.attributes["attributes"])["power"] rescue true
	      ignite     = jsoned_xml.nil? ? true : jsoned_xml

	      # Conversion of speed from knots to km/h
	      speed = speed.to_f * 1.852


	      l = Location.create(device_id: device.try(:id), latitude: lat, longitude: lon, time: fix_time, speed: speed, valid_position: valid,
	          position_id: position_id, status: status, ignite: ignite)

	      Location.where("device_id = ? and DATE(time) = ? and id != ?", l.device_id, l.time.to_date, l.id) do |loc|
	        if loc.time > l.time
	          loc.analyze_me
	        end
	      end

	      l.analyze_me
	    end
	  end
	end
end