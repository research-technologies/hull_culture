require 'iiif_manifest'

module Hyrax
  # This gets mixed into FileSetPresenter in order to create
  # a canvas on a IIIF manifest
  module PrependDisplaysImage
    extend ActiveSupport::Concern

      # Override Hyrax 2.9.3
      def latest_file_id
        @latest_file_id ||=
          begin
            # For some unknown reason the original_file_id is mangling things so will override and just return id
            # Knowing that this will screw things up should file versioning ever be used for this repo (it won't)
            result = id
            if result.blank?
              Rails.logger.warn "original_file_id for #{id} not found, falling back to Fedora."
              result = Hyrax::VersioningService.versioned_file_id ::FileSet.find(id).original_file
            end

            result
          end
      end
  end
end
