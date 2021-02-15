Rails.application.config.to_prepare do
  Hyrax::WorkShowPresenter.prepend Hyrax::PrependWorkShowPresenter
  Hyrax::WorksControllerBehavior.prepend Hyrax::PrependWorksControllerBehavior
end
