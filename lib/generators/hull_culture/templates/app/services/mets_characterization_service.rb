
class MetsCharacterizationService < Hydra::Works::CharacterizationService
    # @param [Hydra::PCDM::File] object which has properties to recieve characterization values.
    # @param [String, File] source for characterization to be run on.  File object or path on disk.
    #   If none is provided, it will assume the binary content already present on the object.
    # @param [Hash] options to be passed to characterization.  parser_mapping:, parser_class:, tools:
    def self.run(object, source = nil, options = {})
      new(object, source, options).characterize
    end

    def initialize(object, source, options)
      @object = object
      @source = source
      @mapping = options.fetch(:parser_mapping, Hydra::Works::Characterization.mapper)
      @parser_class = options.fetch(:parser_class, Hydra::Works::Characterization::FitsDocument)
      @tools = options.fetch(:ch12n_tool, :fits)
    end

    # Get given source into form that can be passed to Hydra::FileCharacterization
    # Use Hydra::FileCharacterization to extract metadata (an OM XML document)
    # Get the terms (and their values) from the extracted metadata
    # Assign the values of the terms to the properties of the object
    def characterize
      extracted_md = extract_metadata(source)
      terms = parse_metadata(extracted_md)
      store_metadata(terms)
    end
end
