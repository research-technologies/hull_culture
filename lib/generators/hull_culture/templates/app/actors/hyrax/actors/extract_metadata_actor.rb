# frozen_string_literal: true

module Hyrax
  module Actors
    # If there is a file called metadata.json, extract the metadata
    #   and merge into attributes
    class ExtractMetadataActor < Hyrax::Actors::AbstractActor
      attr_accessor :uploaded_files, :model

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if create was successful
      def create(env)
        @model = env.curation_concern.class.to_s
        @uploaded_files = filter_file_ids(env.attributes[:uploaded_files])
        env = extract_and_merge(env)
        next_actor.create(env) && true
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        @model = env.curation_concern.class.to_s.underscore
        @uploaded_files = filter_file_ids(env.attributes[:uploaded_files])
        env = extract_and_merge(env)
        next_actor.update(env) && true
      end

      private

      # @param [Array] input
      # @return [Array] uploaded_file_ids for files called 'metadata.json'
      def filter_file_ids(input)
        Array.wrap(input).select(&:present?).select do |f|
          file_path(f).split('/').last.casecmp('metadata.json').zero?
        end
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Hyrax::Actors::Environment] env
      def extract_and_merge(env)
        uploaded_files.each_with_index do |file_id, _index|
          new_attributes = parse(file_id)
          Rails.logger.info('NEW ATTRIBUTES: ')
          Rails.logger.info(new_attributes)
          next if new_attributes.blank?
          env = merge_attributes(env, new_attributes)
        end
        env
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Hyrax::Actors::Environment] env
      def merge_attributes(env, new_attributes)
        keys = env.attributes.keys.map(&:to_sym)
        new_attributes.select { |p| supported?(p.to_sym) }.each do |k, v|
          if keys.include?(k.to_sym)
            next if env.attributes[k] == v
            env = do_merge(env, k, v)
          else
            env.attributes[k] = v
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
      def parse(file_id)
        JSON.parse(File.read(file_path(file_id)))
      rescue JSON::ParserError => e
        Rails.logger.error(e)
      end

      # @param [String] file_id
      # @return [Array] file_path
      def supported?(property)
        return false if property == :id
        if DogBiscuits.config.send("#{model.underscore}_properties").include?(property)
          true
        else
          Rails.logger.warn("Property #{property.to_s} is not supported on #{model}")
          false
        end
      end
    end
  end
end
