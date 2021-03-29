# frozen_string_literal: true

module DogBiscuits
  module VesselType
    extend ActiveSupport::Concern

    included do
      property :vessel_type,
               predicate: ::RDF::URI.new('http://rdf.muninn-project.org/ontologies/naval#hasShipClass') do |index|
        index.as :stored_searchable
      end
    end
  end
end
