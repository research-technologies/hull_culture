# frozen_string_literal: true

# load dog_biscuits config
DOGBISCUITS = YAML.safe_load(File.read(File.expand_path('../dog_biscuits.yml', __dir__))).with_indifferent_access
# include Terms
Qa::Authorities::Local.register_subauthority('organisations', 'DogBiscuits::Terms::OrganisationsTerms')

# Configuration
DogBiscuits.config do |config|
  config.selected_models = %w[DigitalArchivalObject Package]

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

  # can we add the other props here?
  config.facet_properties = %i[packaged_by_titles identifier part_of extent date_uploaded]
  config.index_properties = %i[title date_uploaded packaged_by_titles identifier part_of extent]

  # config.authorities_add_new = %i[]
  # config.singular_properties = %i[]
  # config.facet_only_properties = %i[]

  config.property_mappings[:identifier][:label] = 'Accession Number'
  config.property_mappings[:part_of][:label] = 'Collection'
end
