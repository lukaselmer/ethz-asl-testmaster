namespace :cron do
  desc "Runs the cron task, should run approx every 10 minutes"
  task run: :environment do
    TestRunCron.new.run
  end

end
