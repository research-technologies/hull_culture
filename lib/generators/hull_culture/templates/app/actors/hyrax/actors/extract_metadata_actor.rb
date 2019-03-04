# frozen_string_literal: true

module Hyrax
  module Actors
    # If there is a file called metadata.json, extract the metadata
    #   and merge into attributes
    class ExtractMetadataActor < Hyrax::Actors::AbstractActor
      attr_accessor :uploaded_file_paths, :model

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if create was successful
      def create(env)
        @model = env.curation_concern.class.to_s
        @uploaded_file_paths = filter_file_ids(env.attributes[:uploaded_files])
        env = extract_and_merge(env)
        next_actor.create(env) && true
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        @model = env.curation_concern.class.to_s.underscore
        @uploaded_file_paths = filter_file_ids(env.attributes[:uploaded_files])
        env = extract_and_merge(env)
        next_actor.update(env) && true
      end

      private

      # @param [Array] input
      # @return [Array] uploaded_file_ids for files called 'metadata.json'
      def filter_file_ids(input)
        Array.wrap(input).select(&:present?).map do |f|
          file_path(f) if file_path(f).end_with?('metadata.json')
        end
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Hyrax::Actors::Environment] env
      def extract_and_merge(env)
        uploaded_file_paths.each do |file|
          new_attributes = parse(file)
          next if new_attributes.blank?
          Rails.logger.info('NEW ATTRIBUTES: ')
          Rails.logger.info(new_attributes)
          env = merge_attributes(env, new_attributes)
        end
        env
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Hyrax::Actors::Environment] env
      def merge_attributes(env, new_attributes)
        keys = env.attributes.keys.map(&:to_sym)
        new_attributes.select { |p| supported?(p.to_sym) }.each do |k, v|
          prop = mapping(k.to_sym)
          if keys.include?(prop)
            next if env.attributes[prop] == v
            env = do_merge(env, prop, v)
          else
            env.attributes[prop] = Array.wrap(v)
          end
        end
        env
      end

      # Merge Hashes
      # Concat Arrays and anything else into the Array
      #
      # @param [Hyrax::Actors::Environment] env
      # @param [Symbol] key
      # @param [String] value
      # @return [Hyrax::Actors::Environment] env
      def do_merge(env, key, value)
        if value.is_a?(Hash)
          env.attributes[key].merge(value)
        else
          if env.attributes[key].blank?
            env.attributes[key] = Array.wrap(value)
          else
            env.attributes[key].concat(Array.wrap(value))
          end
        end
        env
      end

      # @param [String] file_id
      # @return [Array] file_path
      def file_path(file_id)
        Hyrax::UploadedFile.find(file_id).file.path
      end

      # @param [String] file_id
      # @return [Hash] hash extracted from json file
      def parse(file)
        return nil if file.blank?
        parsed_json = JSON.parse(File.read(file))
        if parsed_json['packaged_by_package_name']
          get_package_id(parsed_json)
        else
          parsed_json
        end
      rescue JSON::ParserError => e
        Rails.logger.error(e)
        nil
      end
      
      # map any incoming keys to properties
      def mapping(value)
        case value
        when :accession_number
          :identifier
        when :reference
          :part_of
        else
          value
        end
      end
      
      def get_package_id(parsed_json)
        package = Package.search_with_conditions({ title: parsed_json['packaged_by_package_name']}, rows: 1).first[:id]
        parsed_json['packaged_by_ids'] = [package] unless package.nil?
        parsed_json
      end

      # @param [String] file_id
      # @return [Array] file_path
      def supported?(property)
        return false if property == :id
        if DogBiscuits.config.send("#{model.underscore}_properties").include?(mapping(property))
          true
        else
          Rails.logger.warn("Property #{property} is not supported on #{model}")
          false
        end
      end
    end
  end
end
