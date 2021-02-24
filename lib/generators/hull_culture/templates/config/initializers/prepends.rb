Rails.application.config.to_prepare do
  Hyrax::ManifestBuilderService.prepend Hyrax::PrependManifestBuilderService
  Hyrax::WorkShowPresenter.prepend Hyrax::PrependWorkShowPresenter
end
