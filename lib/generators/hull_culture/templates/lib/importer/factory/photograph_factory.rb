# frozen_string_literal: true

module Importer
  module Factory
    class PhotographFactory < BaseFactory
      self.klass = Photograph
      self.system_identifier_field = :identifier
    end
  end
end
