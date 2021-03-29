# frozen_string_literal: true

module DogBiscuits
  module VesselName
    extend ActiveSupport::Concern

    included do
      property :vessel_name, predicate: ::RDF::Vocab::SCHEMA.callSign do |index|
        index.as :stored_searchable
      end
    end
  end
end
