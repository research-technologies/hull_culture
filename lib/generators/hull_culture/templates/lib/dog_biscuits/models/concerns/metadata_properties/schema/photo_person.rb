# frozen_string_literal: true

module DogBiscuits
  module PhotoPerson
    extend ActiveSupport::Concern

    included do
      property :photo_person, predicate: ::RDF::Vocab::SCHEMA.about do |index|
        index.as :stored_searchable
      end
    end
  end
end
