# override - file_set_indexer, extract more, plus new properties
class FileSetIndexerExtended < Hyrax::FileSetIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      # index the extracted_text as ssi
      solr_doc['all_text_ssim'] = object.extracted_text.content if object.extracted_text.present?
      
      # some of these will be numbers
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
      solr_doc['format_label_sim'] = object.characterization_proxy.format_label
      solr_doc['mime_type_sim'] = object.mime_type

      # New FileSet Property
      solr_doc['mets_extracted_tesim'] = object.mets_extracted.to_s

      # AIP terms
      if object.aip_proxy.is_a?(Hydra::PCDM::File)
        solr_doc['aip_file_name_tesim'] = object.aip_proxy.file_name
        solr_doc['aip_format_label_tesim'] = object.aip_proxy.format_label
        solr_doc['aip_format_version_tesim'] = object.aip_proxy.format_version
        solr_doc['aip_format_registry_key_tesim'] = object.aip_proxy.format_registry_key
        solr_doc['aip_format_registry_name_tesim'] = object.aip_proxy.format_registry_name
        solr_doc['aip_original_checksum'] = object.aip_proxy.original_checksum
        solr_doc['aip_original_checksum_algorithm_tesim'] = object.aip_proxy.original_checksum_algorithm
        solr_doc['aip_original_checksum_originator_tesim'] = object.aip_proxy.original_checksum_originator
        solr_doc['aip_normalization_date_tesim'] = object.aip_proxy.normalization_date
        solr_doc['aip_normalization_detail_tesim'] = object.aip_proxy.normalization_detail
        solr_doc['aip_format_label_sim'] = object.aip_proxy.format_label
        solr_doc['aip_format_registry_key_sim'] = object.aip_proxy.format_registry_key
      end

      # SIP terms - some will be numbers
      if object.sip_proxy.is_a?(Hydra::PCDM::File)
        solr_doc['sip_file_name_tesim'] = object.sip_proxy.file_name
        solr_doc['sip_format_version_tesim'] = object.sip_proxy.format_version
        solr_doc['sip_format_registry_key_tesim'] = object.sip_proxy.format_registry_key
        solr_doc['sip_format_registry_name_tesim'] = object.sip_proxy.format_registry_name
        solr_doc['sip_original_checksum_tesim'] = object.sip_proxy.original_checksum
        solr_doc['sip_original_checksum_algorithm_tesim'] = object.sip_proxy.original_checksum_algorithm
        solr_doc['sip_original_checksum_originator_tesim'] = object.sip_proxy.original_checksum_originator
        solr_doc['bit_depth_tesim'] = object.characterization_proxy.bit_depth
        # SIP terms duplicated from original_file (DIP)
        solr_doc['sip_filestatus_message_tesim'] = object.sip_proxy.filestatus_message
        solr_doc['sip_byte_order_tesim'] = object.sip_proxy.byte_order
        solr_doc['sip_capture_device_tesim'] = object.sip_proxy.capture_device
        solr_doc['sip_channels_tesim'] = object.sip_proxy.channels
        solr_doc['sip_character_count_tesim'] = object.sip_proxy.character_count
        solr_doc['sip_character_set_tesim'] = object.sip_proxy.character_set
        solr_doc['sip_color_map_tesim'] = object.sip_proxy.color_map
        solr_doc['sip_color_space_tesim'] = object.sip_proxy.color_space
        solr_doc['sip_compression_tesim'] = object.sip_proxy.compression
        solr_doc['sip_file_creator_tesim'] = object.sip_proxy.creator
        solr_doc['sip_data_format_tesim'] = object.sip_proxy.data_format
        solr_doc['sip_date_created_tesim'] = object.sip_proxy.date_created
        solr_doc['sip_duration_tesim'] = object.sip_proxy.duration
        solr_doc['sip_format_label_tesim'] = object.sip_proxy.format_label
        solr_doc['sip_frame_rate_tesim'] = object.sip_proxy.frame_rate
        solr_doc['sip_gps_timestamp_tesim'] = object.sip_proxy.gps_timestamp
        solr_doc['sip_graphics_count_tesim'] = object.sip_proxy.graphics_count
        solr_doc['sip_image_producer_tesim'] = object.sip_proxy.image_producer
        solr_doc['sip_language_tesim'] = object.sip_proxy.language
        solr_doc['sip_latitude_tesim'] = object.sip_proxy.latitude
        solr_doc['sip_line_count_tesim'] = object.sip_proxy.line_count
        solr_doc['sip_longitude_tesim'] = object.sip_proxy.longitude
        solr_doc['sip_markup_basis_tesim'] = object.sip_proxy.markup_basis
        solr_doc['sip_markup_language_tesim'] = object.sip_proxy.markup_language
        solr_doc['sip_mime_type_tesim'] = object.sip_proxy.mime_type
        solr_doc['sip_mime_type_sim'] = object.sip_proxy.mime_type
        solr_doc['sip_offset_tesim'] = object.sip_proxy.offset
        solr_doc['sip_orientation_tesim'] = object.sip_proxy.orientation
        solr_doc['sip_page_count_tesim'] = object.sip_proxy.page_count
        solr_doc['sip_paragraph_count_tesim'] = object.sip_proxy.paragraph_count
        solr_doc['sip_profile_name_tesim'] = object.sip_proxy.profile_name
        solr_doc['sip_profile_version_tesim'] = object.sip_proxy.profile_version
        solr_doc['sip_sample_rate_tesim'] = object.sip_proxy.sample_rate
        solr_doc['sip_scanning_software_tesim'] = object.sip_proxy.scanning_software
        solr_doc['sip_table_count_tesim'] = object.sip_proxy.table_count
        solr_doc['sip_valid_tesim'] = object.sip_proxy.valid
        solr_doc['sip_well_formed_tesim'] = object.sip_proxy.well_formed
        solr_doc['sip_word_count_tesim'] = object.sip_proxy.word_count
        solr_doc['sip_format_label_sim'] = object.sip_proxy.format_label
        solr_doc['sip_format_registry_key_sim'] = object.sip_proxy.format_registry_key
      end
    end
  end
end
