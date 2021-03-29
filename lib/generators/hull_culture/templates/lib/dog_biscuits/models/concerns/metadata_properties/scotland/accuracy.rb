# frozen_string_literal: true

module DogBiscuits
  module Accuracy
    extend ActiveSupport::Concern

    included do
      property :accuracy,
               predicate: ::RDF::URI.new('http://statistics.gov.scot/def/statistical-quality/accuracy-and-reliability') do |index|
        index.as :stored_searchable
      end
    end
  end
end
