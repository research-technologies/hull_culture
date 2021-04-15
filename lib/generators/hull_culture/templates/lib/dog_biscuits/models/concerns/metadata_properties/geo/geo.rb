module DogBiscuits
  module Geo
    extend ActiveSupport::Concern

    included do
      property :lat,
               predicate: RDF::Vocab::GEO.lat,
               multiple: true do |index|
        index.as :stored_searchable
      end

      property :long,
               predicate: RDF::Vocab::GEO.long,
               multiple: true do |index|
        index.as :stored_searchable
      end

      property :alt,
               predicate: RDF::Vocab::GEO.alt,
               multiple: true do |index|
        index.as :stored_searchable
      end

      # Add wildly unpopular GEO.lat_long propoerty so we can avoid fedora shuffling lat / long pairs
      property :lat_long,
               predicate: RDF::Vocab::GEO.lat_long,
               multiple: true do |index|
        index.as :stored_searchable
      end

    end
  end
end
