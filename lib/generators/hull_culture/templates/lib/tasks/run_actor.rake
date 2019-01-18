
# frozen_string_literal: true

namespace :hull_culture do
  
  desc 'Run extract mets actor'
  task run_actor: :environment do
    Hyrax::UploadedFile.all.each do | file |
      puts "UploadedFile: #{file.id}"
      run_actor(file) unless file.file_set_uri.class == NilClass
    end
  end
  
  def run_actor(file)
      attributes = { uploaded_files: [file.id] }
      curation_concern = FileSet.find(file.file_set_uri.split('/').last).parent
      env = Hyrax::Actors::Environment.new(curation_concern, nil, attributes)
      puts "Processing #{curation_concern.id}"
      Hyrax::Actors::ExtractMetadataActor.new(nil).create(env)
    rescue StandardError => e
      puts "Skipping #{file.id} (#{e.message})" if e.class == TypeError
  end

end
