# == Schema Information
#
# Table name: alarms_rules
#
#  id          :integer          not null, primary key
#  rule_id     :integer          not null
#  alarm_id    :integer          not null
#  conjunction :string(255)
#  params      :string(255)
#

class AlarmRule < ActiveRecord::Base
	self.table_name = "alarms_rules"
	
	belongs_to :rules
	belongs_to :alarms
end