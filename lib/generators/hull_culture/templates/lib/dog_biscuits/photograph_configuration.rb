module DogBiscuits
  class Configuration
    attr_writer :photograph_properties
     def photograph_properties 
        properties = %i[
          title
          abstract
          description
          identifier
          photo_person
          vessel_name
          vessel_type
          date_created
          location
          lat_long
          accuracy
          related_url
          geoname_id
          source
          former_identifier
          part_of
          note
          photo_size
          rights_statement
          rights_holder
          license
        ]
        properties = base_properties + properties + common_properties
        properties.sort!
        @photograph_properties ||= properties
    end

    attr_writer :photograph_properties_required
    def photograph_properties_required
      @photograph_properties_required ||= required_properties
    end

    attr_writer :photograph_nolist_properties
    def photograph_nolist_properties
      @photograph_nolist_properties ||= []
    end

  end
end
