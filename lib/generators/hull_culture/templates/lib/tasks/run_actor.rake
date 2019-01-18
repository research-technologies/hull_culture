# frozen_string_literal: true

namespace :hull_culture do

  desc 'Run extract mets actor'
  task run_actor: :environment do
    Hyrax::UploadedFile.all.each do | file |
      # puts "UploadedFile: #{file.id}"
      run_actor(file) unless file.file_set_uri.class == NilClass
    end
  end

  def run_actor(file)
      attributes = { uploaded_files: [file.id] }
      curation_concern = FileSet.find(file.file_set_uri.split('/').last).parent
      unless curation_concern.nil?
        puts curation_concern.class
        actor = Hyrax::Actors::ExtractMetadataActor.new(Hyrax::Actors::DigitalArchivalObjectActor.new(Hyrax::Actors::Terminator.new)) # Hyrax::CurationConcern.actor
        user = User.find_by(email: curation_concern.depositor)
        ability = Ability.new(user)
        env = Hyrax::Actors::Environment.new(curation_concern, ability, attributes)
        actor.update(env)
        curation_concern.reload
        puts curation_concern.packaged_by if curation_concern.respond_to?(:packaged_by)
        puts "Updating #{curation_concern.id}"
      end
   rescue StandardError => e
      puts "Skipping #{file.id} (#{e.message})" unless e.class == TypeError
  end

end