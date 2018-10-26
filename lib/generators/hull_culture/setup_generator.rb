# frozen_string_literal: true

class HullCulture::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc '
This generator adds Hull Culture Specific changes and configurations.
      '

  def banner
    say_status('info', 'Configuring for Hull Culture', :blue)
  end

  def create_app
    directory 'app', 'app'
  end

  def create_lib
    directory 'lib', 'lib'
  end

  def create_configs
    directory 'config', 'config'
  end

  def create_specs
    directory 'spec', 'spec'
  end
  
  def to_prepare
    actor = "      Hyrax::CurationConcern.actor_factory.insert_after Hyrax::Actors::InitializeWorkflowActor, Hyrax::Actors::ExtractMetadataActor\n"
    application = "config/application.rb"
    application_text = File.read("config/application.rb")
    inject_into_file application, after: 'config.to_prepare do' do
          "\n#{actor}"
    end unless application_text.include?(actor)
  end
end
