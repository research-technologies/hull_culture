if Rails.application.config.active_job.queue_adapter == :sidekiq
  Sidekiq.configure_client do |_config|
    Rails.application.config.after_initialize do
      # @todo don't start multiples
      ExtractFromMetsJob.set(wait_until: Date.tomorrow.midnight).perform_later
    end
  end
end
