# frozen_string_literal: true

require 'dog_biscuits/models/concerns/metadata_properties/scotland/accuracy'
require 'dog_biscuits/models/concerns/metadata_properties/naval/vessel_type'
require 'dog_biscuits/models/concerns/metadata_properties/schema/vessel_name'
require 'dog_biscuits/models/concerns/metadata_properties/schema/photo_person'
require 'dog_biscuits/models/concerns/metadata_properties/ulcc/photo_size'

module DogBiscuits
  module PhotographMetadata
    extend ActiveSupport::Concern
    include DogBiscuits::Abstract #added from dogb
    include DogBiscuits::PartOf #addeed from dogb (aka publication)
    include DogBiscuits::VesselName #new
    include DogBiscuits::VesselType #new
    include DogBiscuits::Accuracy #new
    include DogBiscuits::PhotoSize #new
    include DogBiscuits::PhotoPerson #new
    # Controlled Properties must go last
    include DogBiscuits::CommonMetadata
  end
end
