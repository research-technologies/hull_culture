# A Job class that extracts additonal file metadata an
#   archivematica generated METS
class ExtractFromMetsJob < Hyrax::ApplicationJob
  attr_accessor :skip_extracted
  
  # @param skip_extracted = true [Boolean] skip extraction if done previously
  def perform(skip_extracted = true)
    @skip_extracted = skip_extracted
    process_mets
    reschedule if Rails.application.config.active_job.queue_adapter == :sidekiq
  end

  private

  
  def find_filesets_to_process
    ActiveFedora::SolrService.query('has_model_ssim:"FileSet"',
                                fq: [
                                  '!mets_extracted_tesim:"true"', 
                                  'label_tesim:"METS-*"'
                                  ],
                                fl: ActiveFedora.id_field,
                                rows: 25).map { |x| x.fetch(ActiveFedora.id_field) }
  end

  def process_mets
    find_filesets_to_process.each do |fs|
      MetsExtractJob.perform_later(fs, true)
    end
  end

  def reschedule
    ExtractFromMetsJob.set(wait_until: Date.tomorrow.midnight).perform_later
  end
end
