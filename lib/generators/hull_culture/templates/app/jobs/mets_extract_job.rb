# A Job class that extracts additonal file metadata an
#   archivematica generated METS
class MetsExtractJob < Hyrax::ApplicationJob
  require 'mets_extractor'
  attr_accessor :skip_extracted
  
  queue_as :scheduled
  
  # @param skip_extracted = true [Boolean] skip extraction if done previously
  def perform(file_set_id, skip_extracted = true)
    @skip_extracted = skip_extracted
    process_mets(file_set_id)
  end

  private

  def process_mets(file_set_id)
    result = MetsExtractor.new(FileSet.find(file_set_id), skip_extracted).process
    if result
      Rails.logger.info("File metadata extracted from #{file_set_id}")
    else
      Rails.logger.warn("File metadata was not extracted from #{file_set_id}")
    end
  end
end
