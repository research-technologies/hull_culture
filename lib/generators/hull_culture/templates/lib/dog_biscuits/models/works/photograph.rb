# frozen_string_literal: true

module DogBiscuits
  class Photograph < Work
    # Needed to set the type
    include ::Hydra::Works::WorkBehavior

    # partOf Accession
    #   accessionNumber (subProperty of dcterms:identifier)
    # partOf Collection object

    # Order matters because included metadata finalises things:
    #  1) type and local metadata
    #  2) indexer
    #  3) included metadata

    type << ::RDF::Vocab::SCHEMA.Photograph

    # Indexer
    # self.indexer = DogBiscuits::DigitalArchivalObjectIndexer
    # Metadata
    # include DogBiscuits::DigitalArchivalObjectMetadata

    def photograph?
      true
    end
  end
end
