# frozen_string_literal: true
module Hyrax
  module PrependWorkShowPresenter

    # Override Hyrax 2.5.1 - include pdf
    # @return [Boolean] render a IIIF viewer
    def iiif_viewer?
      representative_id.present? &&
        representative_presenter.present? &&
        (representative_presenter.image? || representative_presenter.pdf?) &&
        Hyrax.config.iiif_image_server? &&
        members_include_viewable_image?
    end

    # Override Hyrax 2.5.1 - include pdf
    def members_include_viewable_image?
      file_set_presenters.any? { |presenter| (presenter.image? || presenter.pdf?) && current_ability.can?(:read, presenter.id) }
    end

    # Override Hyrax 2.5.1 - include pdf
    def display_image
      return nil unless ::FileSet.exists?(id) && current_ability.can?(:read, id) && (solr_document.image? || solr_document.pdf?)
      super
    end
  end
end
