workers Integer(ENV['WEB_CONCURRENCY'] || 5)
threads_count = 1
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+

  # See: https://devcenter.heroku.com/articles/

  # deploying-rails-applications-with-the-puma-web-server#on-worker-boot

  @sidekiq_pid ||= spawn('bundle exec sidekiq -c 2 -q default -q traccar')
  ActiveRecord::Base.establish_connection
end