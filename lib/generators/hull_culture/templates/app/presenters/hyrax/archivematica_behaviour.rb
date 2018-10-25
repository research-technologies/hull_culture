module Hyrax
  module ArchivematicaBehaviour
    extend ActiveSupport::Concern

    class_methods do
      def archivematica_terms
        ::FileSet.aip_terms.collect { |t| "aip_#{t}".to_sym }.concat(::FileSet.sip_terms.collect { |t| "sip_#{t}".to_sym })
      end
    end

    included do
      delegate(*archivematica_terms, to: :solr_document)
    end

    def archivematica_metadata
      @archivematica_metadata ||= build_archivematica_metadata
    end
    
    def mets_extracted?
      true if mets_extracted.first == 'true'
    end

    def archivematica_metadata?
      !archivematica_metadata.values.compact.empty?
    end

    def additional_archivematica_metadata
      @additional_archivematica_metadata ||= {}
    end

    def sip_keys
      archivematica_metadata.keys.select { |k| k.to_s.include?('sip') }.sort
    end

    def aip_keys
      archivematica_metadata.keys.select { |k| k.to_s.include?('aip') }.sort
    end

    def label_for_term_archivematica(term)
      term.to_s.gsub('sip_', '').gsub('aip_', '').titleize
    end

    private

    def build_archivematica_metadata
      self.class.archivematica_terms.each do |term|
        value = send(term)
        additional_archivematica_metadata[term.to_sym] = value if value.present?
      end
      additional_archivematica_metadata
    end
  end
end