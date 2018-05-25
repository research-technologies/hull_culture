# Generated by hyrax:models:install
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior

  self.indexer = FileSetIndexerExtended

  self.characterization_terms = %i[
    bit_depth
    byte_order
    capture_device
    channels
    character_count
    character_set
    color_map
    color_space
    compression
    creator
    data_format
    date_created
    duration
    exif_version
    file_format
    file_size
    file_title
    filename
    fits_version
    format_label
    frame_rate
    gps_timestamp
    graphics_count
    height
    image_producer
    language
    latitude
    line_count
    longitude
    markup_basis
    markup_language
    mime_type
    offset
    orientation
    original_checksum
    page_count
    paragraph_count
    profile_name
    profile_version
    sample_rate
    scanning_software
    table_count
    valid
    well_formed
    width
    word_count
  ]

  
end
