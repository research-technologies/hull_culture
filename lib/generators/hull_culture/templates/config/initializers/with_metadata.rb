# Load the file schemas
Rails.application.configure do
  config.to_prepare do
    require 'archivematica_schema'
    ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas +=
      [
        ArchivematicaSchema
      ]
  end
end
