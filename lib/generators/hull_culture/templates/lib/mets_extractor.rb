# MetsExtractor
#
# Process any archivematica METS file attached to the give FileSet, to extract
#   file metadata and add to the related file_sets.
# Performs these steps:
#   1 Check the number of we expect to update against the number present.
#     stop if the there are more expected than existing, as the objects may
#     not all have been created yet.
#   2 Extract metadata for both original (sip) and preservation (aip) copies
#   3 Add this metadata to the file_set as file objects in the file_set
#     (preservation_master_file and sip_file)
#
# Extracted information (if available):
#   original_checksum_algorithm (sip/aip)
#   original_checksum_originator (sip/aip)
#   format_registry_name (sip/aip)
#   format_registry_key (sip/aip)
#   format_version (sip/aip)
#   format_label (sip/aip)
#   file_size (sip/aip)
#   normalization_date (aip only)
#   normalization_detail (aip only)
#   plus, any additional information we can extract from the fits xml (sip only)
class MetsExtractor
  attr_accessor :file_set, :mets_xml, :skip_extracted

  # Initialize and process
  #
  # @param file_set [FileSet] file_set containing METS
  # @param skip_extracted = true [Boolean] whether to process if METS been
  #   processed
  # @return [Boolean] true if successful, false if not
  def initialize(file_set, skip_extracted = true)
    @file_set = file_set
    @skip_extracted = skip_extracted
  end

  def process
    if skip_extracted == false
      @mets_xml = Nokogiri::XML(file_set.original_file.content).remove_namespaces!
      process_mets
    elsif skip_extracted == true && file_set.mets_extracted.blank?
      @mets_xml = Nokogiri::XML(file_set.original_file.content).remove_namespaces!
      process_mets
    else
      Rails.logger.warn("Skipping, already extracted")
      false
    end
  end

  private

  # Checks that we have the right number of available file_sets, returns false
  #   if not. Otherwise processes sip and aip and returns true.
  def process_mets
    sips = sip_file_nodes
    aips = aip_file_nodes
    Rails.logger.warn("Couldn't find all of the file_sets") if sips.count >= actual_num_filesets
    
    sips.each do |file_node|
      fset = find_referenced_fileset_by_label(file_set_id(file_node))
      if fset.blank?
        Rails.logger.warn(
          "Couldn't find fileset with label #{file_set_id(file_node)}"
        ) unless excluded_label?(file_set_id(file_node))
      else
        add_or_update_file(fset, 'original', file_node)
        fset.reload
        fset.mets_extracted = true
        fset.save
        # Process aip files, assume there is a max of one per sip file
        related_files(file_node).each do |rel|
          node = aips.select { |n| uuid(n) == rel }.first
          unless node.blank?
            add_or_update_file(fset, 'preservation', node)
            fset.reload
            fset.mets_extracted = true
            fset.save
          end
        end
        Rails.logger.info(
          "Updated FileSet #{fset.id}: #{file_set_id(file_node)}"
        )
      end
    end
    file_set.mets_extracted = true && file_set.save unless sips.count >= actual_num_filesets
    true
  rescue StandardError => e
    Rails.logger.error(e.message)
    false
  end

  # @param use [String] file use ('original' or 'preservation')
  # @return [Array] array of hashes
  def nodes_from_mets(use)
    file_ids = mets_xml.search("fileGrp[USE='#{use}']").search('file').map do |o|
      o['ID'].gsub('file-', '')
    end
    file_nodes = file_ids.collect do |file|
      mets_xml.css("objectIdentifierValue[text()*='#{file}']")
    end.reject(&:blank?).flatten!
    file_nodes.collect! { |fn| fn.parent.parent }
  end

  # @param uuid [String] UUID from METS
  # @return [Nokogiri::XML::Node] event node
  def event_node(uuid)
    mets_xml.search('event').select do |e|
      e if e.search('eventIdentifierValue').text.eql?(uuid.to_s)
    end
  end

  # @return [Nokogiri::XML::Node] aip nodes
  def aip_file_nodes
    nodes_from_mets('preservation')
  end

  # @return [Nokogiri::XML::Node] sip nodes
  def sip_file_nodes
    nodes_from_mets('original')
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] label (used to file file_set)
  def file_set_id(node)
    id = uuid(node)
    "#{id}-#{filename(node).gsub("-#{id}", '')}"
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] uuid
  def uuid(node)
    node.css('objectIdentifierValue').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] path
  def file_path(node)
    node.css('originalName').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] filename from path
  def filename(node)
    file_path(node).split('/').last
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] format version
  def format_version(node)
    node.css('formatVersion').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] trimmed format label
  def format_label(node)
    node.css('formatName').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] trimmed format registry name
  def format_registry_name(node)
    node.css('formatRegistryName').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] format registry key
  def format_registry_key(node)
    node.css('formatRegistryKey').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] checksum
  def original_checksum(node)
    node.css('messageDigest').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] checksum algorithm
  def original_checksum_algorithm(node)
    node.css('messageDigestAlgorithm').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] checksum origination
  def original_checksum_originator
    mets_xml.search("mdWrap[MDTYPE='PREMIS:AGENT']").select do |a|
      a if a.css('agentIdentifierType').text.eql?('preservation system')
    end.first.css('agentIdentifierValue').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] file size
  def file_size(node)
    node.css('size').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [XML] fits xml
  def fits(node)
    node.css('fits')
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] exif version
  def exif_version(node)
    node.css('ExifToolVersion').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] fits version
  def fits_version(node)
    node.css('fits').attribute('version').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] normalisation date
  def normalization_date(node)
    uuid = related_events(node).first
    mets_xml.search('event').select do |e|
      e if e.search('eventIdentifierValue').text.eql?(uuid.to_s)
    end.first.css('eventDateTime').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [String] normalization detail
  def normalization_detail(node)
    uuid = related_events(node).first
    mets_xml.search('event').select do |e|
      e if e.search('eventIdentifierValue').text.eql?(uuid.to_s)
    end.first.css('eventDetail').text
  end

  # @param node [Nokogiri::XML::Node]
  # @return [Array] list of related files
  def related_files(node)
    count = node.css('relatedObjectIdentifierValue').count
    return [] if count.zero?
    node.css('relatedObjectIdentifierValue').map(&:text)
  end

  # @param node [Nokogiri::XML::Node]
  # @return [Array] list of related events
  def related_events(node)
    count = node.css('relatedEventIdentification').count
    return [] if count.zero?
    node.css('relatedEventIdentifierValue').map(&:text)
  end

  # Labels should be unique, so return only one
  # @param label [String] fileset label
  # @return [FileSet] filesets with matching label
  # @todo remove Package file_sets in a cleaner way than pattern matching
  def find_referenced_fileset_by_label(label)
    return nil if excluded_label?(label)
    
    fset = FileSet.search_with_conditions({ label: label_formatted(label) }, 
      rows: 1,
      fl: 'id',
      fq: "{!join from=file_set_ids_ssim to=id}packagedBy_ssim:" + file_set.parent.id)
    FileSet.find(fset.first.id) unless fset.blank?
  end
  
  def label_formatted(label)
    label.gsub!(' ', '_')
    label_parts = label.split('.')
    "#{label_parts.first}.#{label_parts.last.downcase}"
  end

  # @param node [Nokogiri::XML::Node]
  # @param use [String] file use ('original' or 'preservation')
  # @param fset [FileSet] file_set to update
  def add_or_update_file(fset, use, node)
    case use
    when 'original'
      file = add_or_update_sip(fset, node)
    when 'preservation'
      file = add_or_update_aip(fset, node)
    end
    return if file.nil?
    file.original_checksum_algorithm = string_to_nil(original_checksum_algorithm(node))
    file.original_checksum_originator = string_to_nil(original_checksum_originator)
    file.format_registry_name = string_to_nil(format_registry_name(node))
    file.format_registry_key = string_to_nil(format_registry_key(node))
    file.format_version = string_to_nil(format_version(node))
    file.format_label = string_to_nil(format_label(node))
    file.file_size = string_to_nil(file_size(node))
    file.file_name = string_to_nil(filename(node))
    file.content = uuid(node)
    file.save
  end

  # @param fset [FileSet] file_set to update
  # @param node [Nokogiri::XML::Node]
  # @return [Hydra::PCDM::File]
  def add_or_update_sip(fset, node)
    file = fset.sip_file || fset.file_of_type('http://london.ac.uk/use#SIPFile')
    fits_metadata = MetsCharacterizationService.new(file, fits(node).to_xml, {})
    fits_metadata.characterize.each do |k, v|
      if file.respond_to?(k)
        file.send("#{k}=", v)
      # elsif k == :file_mime_type
      #   file.mime_type = v
      else
        Rails.logger.warn("Unknown property: #{k}") unless k == :filename || k == :file_mime_type
      end
    end
    file
  end

  # @param fset [FileSet] file_set to update
  # @param node [Nokogiri::XML::Node]
  # @return [Hydra::PCDM::File]
  def add_or_update_aip(fset, node)
    file = fset.preservation_master_file || fset.file_of_type('http://pcdm.org/use#PreservationMasterFile')
    file.normalization_date = normalization_date(node)
    file.normalization_detail = normalization_detail(node)
    file
  end

  # Number of file_sets created from this AIP, includes:
  #   filesets from the package minus two
  #   (METS and processingMCP.xml are not included)
  #   filesets attached to works (DAOs)
  # @return [Integer] number
  def actual_num_filesets
    num = file_set.parent.file_sets.count - 2
    DigitalArchivalObject.search_with_conditions(
      { packagedBy_ssim: file_set.parent.id }, 
      fl: 'file_set_ids_ssim',
      rows: 1000
      ).each { | n | num += n["file_set_ids_ssim"].length}
    num
  end
  
  def excluded_label?(label)
    label.end_with?('-metadata.json') || label.downcase.end_with?('-files.csv') || label.downcase.end_with?('-description.csv') || label.start_with?('METS.') || label == 'processingMCP.xml'
  end
  
  def string_to_nil(string)
    if string.blank?
      nil
    else
      string
    end
  end
end
