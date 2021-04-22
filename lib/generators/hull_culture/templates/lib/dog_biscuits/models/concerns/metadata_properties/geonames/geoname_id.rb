# frozen_string_literal: true

module DogBiscuits
  module GeonameId
    extend ActiveSupport::Concern

    included do
      property :geoname_id, predicate: ::RDF::URI.new('https://www.wikidata.org/wiki/Property:P1566') do |index|
        index.as :stored_searchable
      end
    end
  end
end
