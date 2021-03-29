# frozen_string_literal: true

# load dog_biscuits config
DOGBISCUITS = YAML.safe_load(File.read(File.expand_path('../dog_biscuits.yml', __dir__))).with_indifferent_access
# include Terms
Qa::Authorities::Local.register_subauthority('organisations', 'DogBiscuits::Terms::OrganisationsTerms')

DogBiscuits::Configuration.class_eval do
    # All available models
    def available_models
      ['ConferenceItem', 'Dataset', 'DigitalArchivalObject', 'ExamPaper', 'JournalArticle', 'Package', 'PublishedWork', 'Thesis', 'Photograph'].freeze
    end
end

# TODO work out how to do the DB autoloads properly
require 'dog_biscuits/photograph_configuration'
require 'dog_biscuits/models/works/photograph'
require 'dog_biscuits/models/concerns/model_property_sets/photograph_metadata'
require 'dog_biscuits/indexers/photograph_indexer'

# Configuration
DogBiscuits.config do |config|
  config.selected_models = %w[DigitalArchivalObject Package Photograph]

  config.digital_archival_object_properties = %i[
    title
    identifier
    part_of
    extent
    packaged_by_ids
  ]
  config.digital_archival_object_properties_required = %i[
    title
    identifier
    part_of
  ]
  config.package_properties = %i[
    title
    identifier
    aip_uuid
    transfer_uuid
    sip_uuid
    dip_uuid
    aip_status
    dip_status
    aip_size
    dip_size
    aip_current_path
    dip_current_path
    aip_current_location
    dip_current_location
    aip_resource_uri
    dip_resource_uri
    origin_pipeline
    package_ids
  ]
  config.package_properties_required = %i[title identifier]

  config.photograph_properties = %i[
    title
    abstract
    vessel_name
    vessel_type
    creator
    date
    location
    lat
    long
    accuracy
    source
    former_identifier
    part_of
    related_url
    extent
    rights_statement
  ]
  config.photograph_properties_required = %i[
    title
    creator
    date
  ]
  
  # can we add the other props here?
  config.facet_properties = %i[packaged_by_titles identifier part_of extent date_uploaded]
  config.index_properties = %i[title date_uploaded packaged_by_titles identifier part_of extent]

  # config.authorities_add_new = %i[]
  # config.singular_properties = %i[]
  # config.facet_only_properties = %i[]

  config.property_mappings[:identifier][:label] = 'Accession Number'
  config.property_mappings[:part_of][:label] = 'Collection'

  config.property_mappings[:vessel_name] = { label: 'Name of Vessel',
    help_text: 'The name of the vessel pictured',
    index: [{ link_to_search: true }]
  }

  config.property_mappings[:vessel_type] = { label: 'Type of Vessel',
    help_text: 'The type of the vessel pictured',
    index: [{ link_to_search: true }]
  }

  config.property_mappings[:accuracy] = { label: 'Accuracy',
    help_text: 'A measure of accuracy of the geographic data associated with this item',
    index: [{ link_to_search: false }]
  }

end
