# This module points the FileSet to the location of the metdata derived from
# archivematica via the METS file.
#
# It follows the Hyrax::FileSet::Characterization implementation
module Archivematica
  extend ActiveSupport::Concern

  included do
    class_attribute :aip_terms, :aip_proxy, :sip_terms, :sip_proxy

    self.aip_terms = %i[
      format_label
      format_version
      format_registry_key
      format_registry_name
      original_checksum
      original_checksum_algorithm
      original_checksum_originator
      normalization_date
      normalization_detail
      file_name
    ]
    self.sip_terms = %i[
      format_version
      format_registry_key
      format_registry_name
      original_checksum_algorithm
      original_checksum_originator
      filestatus_message
      file_name
    ]

    self.aip_proxy = :preservation_master_file
    self.sip_proxy = :sip_file

    delegate(*aip_terms, to: :aip_proxy)
    delegate(*sip_terms, to: :sip_proxy)

    def aip_proxy
      send(self.class.aip_proxy) || NilClass
    end

    def sip_proxy
      send(self.class.sip_proxy) || NilClass
    end

    def aip_proxy?
      !aip_proxy.is_a?(NilClass)
    end

    def sip_proxy?
      !sip_proxy.is_a?(NilClass)
    end
  end
end
