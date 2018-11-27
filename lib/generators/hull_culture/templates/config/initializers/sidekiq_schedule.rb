# Schedule the nightly ExtractFromMetsJob if it isn't already scheduled

if Rails.application.config.active_job.queue_adapter == :sidekiq
  require 'sidekiq/api'
  Sidekiq.configure_client do |_config|
    Rails.application.config.after_initialize do
      ExtractFromMetsJob.set(wait_until: Date.tomorrow.midnight).perform_later
    end if Sidekiq::Stats.new.scheduled_size == 0
  end
end
