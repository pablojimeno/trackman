# == Schema Information
#
# Table name: simcards
#
#  id               :integer          not null, primary key
#  telephone_number :string(255)
#  teleprovider_id  :integer
#  monthly_price    :float(24)
#  device_id        :integer
#  created_at       :datetime
#  updated_at       :datetime
#  company_id       :integer
#  deleted_at       :datetime
#  name             :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :simcard do
    telephone_number "NewSimcard"
    teleprovider_id 1
    monthly_price 1.5
    device_id 1
  end
end
