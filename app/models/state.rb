# == Schema Information
#
# Table name: states
#
#  id         :integer          not null, primary key
#  no_data    :boolean          default(FALSE)
#  moving     :boolean          default(FALSE)
#  car_id     :integer
#  created_at :datetime
#  updated_at :datetime
#  speed      :float(24)        default(0.0)
#  driver_id  :integer
#  device_id  :integer
#

class State < ActiveRecord::Base
  belongs_to :car
  belongs_to :device

  # validation
  validates :car_id, presence: true

end
