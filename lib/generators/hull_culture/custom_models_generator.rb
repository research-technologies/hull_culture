# frozen_string_literal: true

class HullCulture::CustomModelsGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  desc '
This generator adds specific properties.
      '

  def banner
    say_status('info', 'Configuring models', :blue)
  end

  # Assumed files have been copied into place by the setup_generator

  # add custom fields
  def update_custom_properties
    # properties
    properties = [] # matches name of concern so camelized

    models = %w[] # matches file_name so underscore
    models.each do |m|
      file_text = File.read("app/models/#{m}.rb")
      properties.each do |p|
        next if file_text.include? p
        inject_into_file "app/models/#{m}.rb", after: 'WorkBehavior' do
          "\n  include #{p}"
        end
      end
    end

    # solr_doc
    properties.each do |p|
      solr_doc = "\n  attribute :#{p.downcase}, Solr::Array, solr_name('#{p.downcase}')\n"
      next if File.read('app/models/solr_document.rb').include? p.downcase
      inject_into_file 'app/models/solr_document.rb', before: "\nend\n" do
        solr_doc
      end
    end
  end
end
