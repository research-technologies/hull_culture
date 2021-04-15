# frozen_string_literal: true

module DogBiscuits
  module PhotoSize
    extend ActiveSupport::Concern

    included do
      property :photo_size, predicate: ::RDF::URI.new('http://london.ac.uk/ontologies/terms#photoSize') do |index|
        index.as :stored_searchable
      end
    end
  end
end
