class ArchivematicaSchema < ActiveTriples::Schema
  property :original_checksum, predicate: RDF::Vocab::NFO.hashValue
  property :format_version, predicate: RDF::Vocab::PREMIS.hasFormatVersion
  property :format_registry_key, predicate: RDF::Vocab::PREMIS.hasFormatRegistryKey
  property :format_registry_name, predicate: RDF::Vocab::PREMIS.hasFormatRegistryName
  property :original_checksum_algorithm, predicate: RDF::Vocab::PREMIS.hasMessageDigestAlgorithm
  property :original_checksum_originator, predicate: RDF::Vocab::PREMIS.hasMessageDigestOriginator
  property :normalization_date, predicate: RDF::Vocab::PREMIS.hasEventDateTime
  property :normalization_detail, predicate: RDF::Vocab::PREMIS.hasEventDetail
  property :filestatus_message, predicate: RDF::URI('http://london.ac.uk/file#filestatusMessage')
end