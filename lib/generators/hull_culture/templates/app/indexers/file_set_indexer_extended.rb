
# file_set_indexer
class FileSetIndexerExtended < Hyrax::FileSetIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      # some of these we'll want to be numbers
      solr_doc['bit_depth_tesim'] = object.characterization_proxy.bit_depth
      solr_doc['byte_order_tesim'] = object.characterization_proxy.byte_order
      solr_doc['capture_device_tesim'] = object.characterization_proxy.capture_device
      solr_doc['channels_tesim'] = object.characterization_proxy.channels
      solr_doc['character_count_tesim'] = object.characterization_proxy.character_count
      solr_doc['character_set_tesim'] = object.characterization_proxy.character_set
      solr_doc['color_map_tesim'] = object.characterization_proxy.color_map
      solr_doc['color_space_tesim'] = object.characterization_proxy.color_space
      solr_doc['compression_tesim'] = object.characterization_proxy.compression
      solr_doc['file_creator_tesim'] = object.characterization_proxy.creator
      solr_doc['data_format_tesim'] = object.characterization_proxy.data_format
      solr_doc['date_created_tesim'] = object.characterization_proxy.date_created
      solr_doc['duration_tesim'] = object.characterization_proxy.duration
      solr_doc['format_label_tesim'] = object.characterization_proxy.format_label
      solr_doc['frame_rate_tesim'] = object.characterization_proxy.frame_rate
      solr_doc['gps_timestamp_tesim'] = object.characterization_proxy.gps_timestamp
      solr_doc['graphics_count_tesim'] = object.characterization_proxy.graphics_count
      solr_doc['image_producer_tesim'] = object.characterization_proxy.image_producer
      solr_doc['language_tesim'] = object.characterization_proxy.language
      solr_doc['latitude_tesim'] = object.characterization_proxy.latitude
      solr_doc['line_count_tesim'] = object.characterization_proxy.line_count
      solr_doc['longitude_tesim'] = object.characterization_proxy.longitude
      solr_doc['markup_basis_tesim'] = object.characterization_proxy.markup_basis
      solr_doc['markup_language_tesim'] = object.characterization_proxy.markup_language
      solr_doc['offset_tesim'] = object.characterization_proxy.offset
      solr_doc['orientation_tesim'] = object.characterization_proxy.orientation
      solr_doc['page_count_tesim'] = object.characterization_proxy.page_count
      solr_doc['paragraph_count_tesim'] = object.characterization_proxy.paragraph_count
      solr_doc['profile_name_tesim'] = object.characterization_proxy.profile_name
      solr_doc['profile_version_tesim'] = object.characterization_proxy.profile_version
      solr_doc['sample_rate_tesim'] = object.characterization_proxy.sample_rate
      solr_doc['scanning_software_tesim'] = object.characterization_proxy.scanning_software
      solr_doc['table_count_tesim'] = object.characterization_proxy.table_count
      solr_doc['valid_tesim'] = object.characterization_proxy.valid
      solr_doc['well_formed_tesim'] = object.characterization_proxy.well_formed
      solr_doc['word_count_tesim'] = object.characterization_proxy.word_count
    end
  end
end
