Rails.application.configure do
  config.to_prepare do
    Hyrax::CurationConcern.actor_factory.insert_after Hyrax::Actors::InitializeWorkflowActor,
                                                      Hyrax::Actors::ExtractMetadataActor
  end
end
