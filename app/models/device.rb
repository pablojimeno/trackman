# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  emei            :string(255)
#  cost_price      :float(24)
#  created_at      :datetime
#  updated_at      :datetime
#  device_model_id :integer
#  device_type_id  :integer
#  car_id          :integer
#  company_id      :integer
#  movement        :boolean
#  last_checked    :datetime
#  deleted_at      :datetime
#

class Device < ActiveRecord::Base
  # INIT GEM
  include ActionView::Helpers::DateHelper
  acts_as_paranoid
  acts_as_tenant(:company)

  # Validation
  validates :name, :emei, :device_model_id, :device_type_id, presence: true
  validates_uniqueness_of :name, conditions: -> { where(deleted_at: nil) }, case_sensitive: false
  validates_uniqueness_of :emei, conditions: -> { where(deleted_at: nil) }, case_sensitive: false

  # Scopes
  scope :by_device_model, -> device_model_id { where(:device_model_id => device_model_id) }
  scope :by_device_type, -> device_type_id { where(:device_type_id => device_type_id) }
  scope :with_simcard, -> { where("id IN (SELECT device_id FROM Simcards WHERE device_id IS NOT NULL)") }
  scope :without_simcard, -> { where("id NOT IN (SELECT device_id FROM Simcards WHERE device_id IS NOT NULL)") }
  scope :available, -> { where(:car_id => nil) }
  scope :used, -> { where("car_id IS NOT NULL") }

  # ASSOCIATION
  has_one :simcard, :dependent => :nullify
  belongs_to :device_model
  belongs_to :device_type
  belongs_to :car
  belongs_to :company
  has_many :states
  has_many :locations

  # CALLBACKS
  before_destroy :destroy_traccar_device
  after_save :create_traccar_device
  before_update :update_traccar_device

  # CLASS METHODS
  def self.sync_to_traccar
    Device.all.each do |d|
      if Traccar::Device.find_by_uniqueId(d.emei).nil?
        d.save!
      end
    end
  end

  def self.import(file)
    status = {}
    begin
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        device = find_by_id(row["id"]) || new
        device.attributes = row.to_hash.slice(*accessible_attributes)
        device.save!
        status[:message] = "Devices imported!"
        status[:alert] = "success"
      end
    rescue => exception
      status[:message] = exception
      status[:alert] = "danger"
    end

    return status
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.available_devices
    Device.where(:car_id => nil)
  end

  def self.without_simcards(device_id)
    if device_id.nil?
      Device.where("id NOT IN (SELECT device_id FROM simcards WHERE device_id IS NOT NULL)")
    else
      Device.where("id NOT IN (SELECT device_id FROM simcards WHERE device_id IS NOT NULL) OR id = #{device_id}")
    end
  end

  # INSTANCE METHOD
  def destroy_traccar_device
    self.traccar_device.destroy unless self.traccar_device.nil?
  end

  def create_traccar_device
    traccar_device = Traccar::Device.find_or_create_by(name: self.name, uniqueId: self.emei)
    traccar_device.users << Traccar::User.where(:name => "admin", :email => "admin")
  end

  def update_traccar_device
    traccar_device = Traccar::Device.where(uniqueId: self.emei).first
    unless traccar_device.nil?
      traccar_device.update_attributes(name: self.name, uniqueId: self.emei)
    end
  end

  def has_car?
    !self.car_id.nil?
  end

  def has_simcard?
    !self.simcard.nil?
  end

  def last_position
    # self.try(:traccar_device).try(:last_position)
    self.locations.last
  end

  def last_positions(number=2)
    unless self.traccar_device.nil?
      self.traccar_device.last_positions(number)
    end
  end

  def positions
    unless self.traccar_device.nil?
      self.traccar_device.positions
    end
  end

  # check if the device is reporting that the car is moving (or not)
  def moving?(precision = 0.0001)

    last_positions = self.last_positions(2).to_a

    # find last state for this car
    last_state = self.states.last

    if last_positions.count == 2
      latitude1 = last_positions[0].latitude
      longitude1 = last_positions[0].longitude
      latitude2 = last_positions[1].latitude
      longitude2 = last_positions[1].longitude

      threshold = precision
      Time.use_zone('UTC') do
        if (latitude1 - latitude2).abs < threshold
          self.update_attributes(:movement => false, :last_checked => Time.zone.now)
          return false
        else
          self.update_attributes(:movement => true, :last_checked => Time.zone.now)
          return true
        end
      end
    else
      return false
    end
  end

  def no_data?
    last_position = self.traccar_device.positions.last

    return true if last_position.nil?

    seconds = Time.zone.now - last_position.fixTime.in_time_zone

    #return "#{time_ago_in_words(last_position.time)} ago OR #{since} seconds"

    if seconds >= 20.minutes
      return true
    else
      return false
    end
  end

  # return the speed of the vehicle associated with the last position
  def speed
    self.traccar_device.try(:positions).try(:last).try(:speed)
  end

  def traccar_device
    Traccar::Device.where(uniqueId: self.emei).first
  end
end
