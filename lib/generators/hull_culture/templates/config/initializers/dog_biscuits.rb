# frozen_string_literal: true

# load dog_biscuits config
DOGBISCUITS = YAML.safe_load(File.read(File.expand_path('../../dog_biscuits.yml', __FILE__))).with_indifferent_access
# include Terms
Qa::Authorities::Local.register_subauthority('organisations', 'DogBiscuits::Terms::OrganisationsTerms')

# Configuration
DogBiscuits.config do |config|
  config.selected_models = %w[DigitalArchivalObject]

  # config.digital_archival_object_properties = %i[]
  # config.digital_archival_object_required = %i[]
  # config.package_properties = %i[]
  # config.package_properties_required = %i[]
  # config.facet_properties = %i[]
  # config.index_properties = %i[]
  # config.authorities_add_new = %i[]
  # config.singular_properties = %i[]
  # config.facet_only_properties = %i[]

end
