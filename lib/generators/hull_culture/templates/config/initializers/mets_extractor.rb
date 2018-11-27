Hyrax.config do | config |
    Hyrax::CurationConcern.actor_factory.insert_after Hyrax::Actors::InitializeWorkflowActor,
                                                      Hyrax::Actors::ExtractMetadataActor
end
