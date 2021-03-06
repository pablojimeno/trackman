# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  subdomain  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  plan_id    :integer
#  time_zone  :string(255)
#

FactoryGirl.define do 
    factory :company do
        sequence(:name) { |n| "Company #{n}" }
        sequence(:subdomain) { |n| "subdomain#{n}" }
        time_zone "Copenhagen"
    end
end
