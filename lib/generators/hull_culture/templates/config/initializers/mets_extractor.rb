Hyrax.config do | config |
    Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::CreateWithFilesOrderedMembersActor,
                                                      Hyrax::Actors::ExtractMetadataActor
end
