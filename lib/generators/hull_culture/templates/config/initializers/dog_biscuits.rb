# frozen_string_literal: true

# load dog_biscuits config
DOGBISCUITS = YAML.safe_load(File.read(File.expand_path('../../dog_biscuits.yml', __FILE__))).with_indifferent_access
# include Terms
Qa::Authorities::Local.register_subauthority('organisations', 'DogBiscuits::Terms::OrganisationsTerms')

# Configuration
DogBiscuits.config do |config|
  config.selected_models = %w[DigitalArchivalObject Package]

  config.digital_archival_object_properties = %i[
    title 
    identifier 
    access_provided_by 
    part_of 
    extent 
    lat 
    long 
    alt 
    packaged_by_ids
  ]
  config.digital_archival_object_properties_required = %i[
    title 
    identifier 
    access_provided_by 
    part_of
  ]
  config.package_properties = %i[
    title
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
  config.package_properties_required = %i[title]
  
  config.facet_properties += %i[access_provided_by package_titles]
  config.index_properties += %i[access_provided_by]

  # config.authorities_add_new = %i[]
  # config.singular_properties = %i[]
  # config.facet_only_properties = %i[]

  config.property_mappings[:part_of][:label] = 'Accession'
end
