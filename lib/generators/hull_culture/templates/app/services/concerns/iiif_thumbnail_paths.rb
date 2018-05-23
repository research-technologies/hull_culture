# frozen_string_literal: true

module IIIFThumbnailPaths
  extend ActiveSupport::Concern

  class_methods do
    # @param [FileSet] file_set
    # @param [String] size ('!150,300') an IIIF image size defaults to an image no
    #                      wider than 150px and no taller than 300px
    # @return the IIIF url for the thumbnail if it's an image, otherwise gives
    #         the thumbnail download path
    def thumbnail_path(file_set, size = '!150,300')
      return super(file_set) unless file_set.image?
      iiif_thumbnail_path(file_set, size)
    end

    # During ingest the digest will not be available and the thumbnail indexer will receive nil;
    #   it will default back to the standard thumbnail path
    #   later in the ingest process the indexer will run again and get the correct path
    def iiif_thumbnail_path(file_set, size)
      return unless file_set.original_file
      if ENV['IIIF_IMAGE_ENDPOINT']
        if file_set.original_file.digest
          file = file_set.original_file.digest[0].to_s.split(':').last
          "#{ENV['IIIF_IMAGE_ENDPOINT']}?IIIF=/#{file[0..1]}/#{file[2..3]}/#{file[4..5]}/#{file}/full/#{size},/0/default.jpg"
        end
      else
        file = file_set.original_file
        Riiif::Engine.routes.url_helpers.image_path(
          file.id,
          size: size
        )
      end
    rescue StandardError
      Rails.logger.warn("Something went wrong when trying to get the thumbnail path for #{file_set.id} original file #{file_set.original_file}")
      nil
    end

    def thumbnail?(_thumbnail)
      true
    end
  end
end
