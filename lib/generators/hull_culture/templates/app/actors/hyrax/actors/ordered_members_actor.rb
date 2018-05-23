# frozen_string_literal: true

module Hyrax
  module Actors
    # Actions are decoupled from controller logic so that they may be called from a controller or a background job.
    class OrderedMembersActor
      include Lockable
      attr_reader :ordered_members

      def initialize(ordered_members)
        @ordered_members = ordered_members
      end

      # Adds FileSets to the work using ore:Aggregations.
      # Locks to ensure that only one process is operating on the list at a time.
      # This has been extracted from FileSetActor and does a batch add
      def attach_to_work(work)
        acquire_lock_for(work.id) do
          Rails.logger.info("Add FileSets to Work in one action - start")
          work.ordered_members = ordered_members
          # Save the work so the association between the work and the file_set is persisted (head_id)
          # NOTE: the work may not be valid, in which case this save doesn't do anything.
          work.save
          Rails.logger.info("Add FileSets to Work in one action - finish")
        end
      end

      def run_callback(user)
        ordered_members.each do | file_set |
          Hyrax.config.callback.run(:after_create_fileset, file_set, user)
        end
      end
    end
  end
end
