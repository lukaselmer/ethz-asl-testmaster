namespace :cron do
  desc "Runs the cron task, should run approx every 10 minutes"
  task run: :environment do
    lock_file = "#{Rails.root}/tmp/cron.lock"
    unless File.exist? lock_file
      begin
        File.open(lock_file, File::RDWR|File::CREAT, 0644).flock(File::LOCK_EX)
        TestRunCron.new.run
      rescue => e
        ExceptionNotifier.notify_exception(e)
        raise e
      ensure
        File.delete(lock_file) if File.exist?(lock_file)
      end
    end
  end

  task analyze: :environment do
    lock_file = "#{Rails.root}/tmp/analyze.lock"
    unless File.exist? lock_file
      begin
        File.open(lock_file, File::RDWR|File::CREAT, 0644).flock(File::LOCK_EX)
        AnalyzeCron.new.run
      rescue => e
        ExceptionNotifier.notify_exception(e)
        raise e
      ensure
        File.delete(lock_file) if File.exist?(lock_file)
      end
    end
  end

end
