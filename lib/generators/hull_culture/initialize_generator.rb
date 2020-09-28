# frozen_string_literal: true

class HullCulture::InitializeGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  desc '
This generator adds runs Hull Culture initialization tasks.
      '

  def banner
    say_status('info', 'Initializations for Hull Culture', :blue)
  end

  def initial_rake_tasks
    rails_command 'db:migrate'
    rails_command 'db:setup'
    # install browser everything 
    generate 'browse_everything:install', '-f'
    rake('hyrax:default_admin_set:create')
    rake('hyrax:workflow:load')
    rake('hyrax:default_collection_types:create')
    rake('hull_culture:colors')
    rake('hull_culture:announcement')
  end
end
