module DogBiscuits
  class Configuration
    attr_writer :photograph_properties
     def photograph_properties 
        properties = %i[
          title
          abstract
          vessel_name
          vessel_type
          creator
          date
          location
          lat
          long
          accuracy
          source
          former_identifier
          part_of
          realted_url
          extent
          rights
        ]
        properties = base_properties + properties + common_properties
        properties.sort!
        @photograph_properties ||= properties
    end

    attr_writer :photograph_properties_required
    def photograph_properties_required
      @photograph_properties_required ||= required_properties
    end

  end
end
