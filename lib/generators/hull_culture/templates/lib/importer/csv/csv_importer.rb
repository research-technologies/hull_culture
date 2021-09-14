# frozen_string_literal: true
require 'csv'

module Importer
  # Imports Marc metadata
  module Csv
    class CsvImporter
      attr_accessor :model, :metadata_file

      mattr_accessor :csv_mappings


      self.csv_mappings = {
        :identifier => ['Collection', 'Box Number', 'Item Number'],
        :description => 'Brief Description',
        :source => 'Source',
        :former_identifier => 'Original Reference',
        :location => 'Location Place',
        :bibliographic_citation => 'Publication',
        :note => 'Additional Comments',
        :vessel_name => 'Vessel Name',
        :photo_size => 'Print Size',
        :photo_person => 'People Names',
        :lat_long => 'New location lat/long',
        :accuracy => 'New accuracy',
        :date_created => 'New date',
        :related_url => 'Street view URL',
#        'Title' => , #Not used.... Like repo title but without the Item number prepended to it.
        :license => 'Licence', #always Restricted (which isn't a license) in CSV, we have hard coded these (license, rights_statement) as special attributes below (until we find out what to do otherwise)
        :rights_statement => 'License',
#        :rights_holder => 'License',
        :geoname_id => 'Geonames URL',
        :vessel_type => 'Vessel Type text',
        :filename => 'Filename',
        :title => 'RepoTitle',
        :comment => 'RG comments'
      }

      def initialize(metadata_file,downloads_dir)
        @metadata_file = metadata_file
        @model = "Photograph"
        @downloads_dir=downloads_dir
      end

      # Import the items
      #
      # @return count of items imported
      attr_accessor :attributes, :row
      def import_all
        count = 0
        csv = CSV.parse(File.read(metadata_file, encoding: 'bom|utf-8'), headers: true)
        csv.each do |csv_row|
          @attributes = {}
          @row = csv_row.to_h
          standard_attributes
          special_attributes
          puts "#{attributes}"
          next if attributes.blank?
          attributes[:edit_groups] = ['admin']
          object = create_fedora_objects(attributes)
          write_to_files_list_csv(object.id,row["Filename"])
         # puts "#{object.id},#{row['Filename']}"
          count += 1
        end
        message = "Imported #{count} record(s).\n"
        message
      end

      private

        # Create a parser object with the metadata file
        def standard_attributes
          #TODO split multiple values on " / "
          csv_mappings.each do | a_key, csv_key |
            next if special_attributes_list.include?(a_key)
            if row[csv_key].present? and row[csv_key].include?(" / ")
              attributes[a_key] = row[csv_key].split(/ \/ /)
            else
              attributes[a_key] = Array.wrap(row[csv_key]) unless row[csv_key].blank?
            end
          end
          attributes
        end

        # creator / editor
        def special_attributes_list
          [:identifier, :filename, :rights_statement, :license]
        end
        
        def special_attributes
          special_attributes_list.each do |special|
            send(special)
          end
        end  

        def identifier
          keys = csv_mappings[:identifier]
          attributes[:identifier] = ["#{row[keys[0]]}C-#{row[keys[1]]}-#{row[keys[2]]}"]
        end

       def filename
         puts "Write this to a csv file for attachment later #{row[csv_mappings[:filename]]}"
       end
       
       def license
         attributes[:license] = ["http://www.hullhistorycentre.org.uk/about-us/about/HHC-Access-Policy.pdf"]
       end

       def rights_statement
         attributes[:rights_statement] = ["http://rightsstatements.org/vocab/InC/1.0/"]
       end

       # Build a factory to create the objects in fedora.
       #
       # @param attributes [Hash] the object attributes
       def create_fedora_objects(attributes)
         Factory.for(model).new(attributes).run
       end

      # @param db_id [Array] uploaded file 
      def write_to_files_list_csv(object_id, filename)
        files_csv = File.join(@downloads_dir, 'files.csv')
        line = ''
        line += "#{object_id},#{filename}\n"
        if File.exist?(files_csv) && !File.read(files_csv).include?(line)
          File.open(files_csv, 'a+') { |f| f << line }
        else
          File.open(files_csv, 'w') { |f| f << line }
        end
      end

    end
  end
end
