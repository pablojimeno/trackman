# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
# Learn more: http://github.com/javan/whenever


# To generate cron jobs for this file
# whenever --update-crontab trackman

# crontab -r 
# whenever --update-crontab --set environment='development'


every 3.minute do 
	rake "check:which_cars_are_moving"
end

every 2.minute do 
	rake "jobs:workoff"
end

every 1.minute do 
	rake "simulate:random_cars"
end