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

=begin

######################################
# Photograph model (bit specific) add for Basil Greenhill collection
#
# * Properties new to dog biscuits
######################################
          title
          description
          identifier
*         photo_person (as in the person in the photo)
*         vessel_name
*         vessel_type
          date_created
          location
          geoname_id
*         lat_long #combined version to avoid lat/long mix up
*         accuracy #arbitrary measure of accuracy of the geo data
          related_url #geonames reference
          source
          former_identifier # Original Reference
          bibliographic_citation #(Publication, which is really a citation/reference from a publication)
          note #Additional information
*         photo_size
          rights_statement
          rights_holder
          license
=end

  config.photograph_properties = %i[
          title
          description
          identifier
          photo_person
          vessel_name
          vessel_type
          date_created
          location
          geoname_id
          lat_long
          accuracy
          related_url
          source
          former_identifier
          bibliographic_citation
          note
          comment
          photo_size
          rights_statement
          rights_holder
          license
  ]
  config.photograph_properties_required = %i[
    title 
  ]
  
  config.photograph_nolist_properties = %i[
    title identifier license geoname_id
  ]

  # can we add the other props here?
  config.facet_properties = %i[
    packaged_by_titles 
    identifier 
    part_of 
    extent 
    date_uploaded 
    vessel_name
    vessel_type
    photo_person
    location
  ]
  #Index properties == properties that get shown on the result page (as opposed to those things twhat are indexed)
  config.index_properties = %i[title vessel_type photo_person date_uploaded packaged_by_titles identifier part_of extent]

  # config.authorities_add_new = %i[]
  config.singular_properties = %i[ rights_statement ]
  # config.facet_only_properties = %i[]

  config.property_mappings[:identifier][:label] = 'Accession Number / Identifier'
  config.property_mappings[:part_of][:label] = 'Collection / Publication'
#  config.property_mappings[:part_of][:label] = 'Publication' #todo split label for Photograph / DAO => Collection / Publication

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

  config.property_mappings[:photo_size] = { label: 'Size of photograph',
    help_text: 'The dimensions of the original photograph'
  }

  config.property_mappings[:photo_person] = { label: 'People in Photograph',
    help_text: 'People or person featured in photograph'
  }

  config.property_mappings[:comment] = { label: 'Comment',
    help_text: 'Comment',
    index: [{ link_to_search: true }]
  }

  config.property_mappings[:date_created] = { label: 'Date'}

  config.property_mappings[:former_identifier][:label] = 'Original Reference'
  config.property_mappings[:related_url] = { label: 'Modern day view', help_text: 'A streetview URL representing a current view of the scene photographed', render_as: 'streetview_url' }
  config.property_mappings[:geoname_id] = { label: 'Geonames ID', help_text: 'The Numeric Geonames ID (e.g. 12345) used to construct a valid geonames URL'}
  config.property_mappings[:location] = { label: 'Location', render_as: 'geonames_url'}
  config.property_mappings[:lat_long] = { label: 'Latitude / Longitude', render_as: 'google_maps_lat_long' }
  config.property_mappings[:note] = {label: 'Additional Information', render_as: 'simple_format' }
  config.property_mappings[:description] = { label: 'Description', render_as: 'simple_format' }
  config.property_mappings[:bibliographic_citation] = { label: 'Bibliographic Citation' }



end
