# frozen_string_literal: true

module DogBiscuits
  module Comment
    extend ActiveSupport::Concern

    included do
      property :comment, predicate: ::RDF::Vocab::SCHEMA.comment do |index|
        index.type :text
        index.as :stored_searchable, :sortable
      end
    end
  end
end
