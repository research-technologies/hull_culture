# frozen_string_literal: true

class HullCulture::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  class_option :initial, type: :boolean, default: false

  desc '
  Install, generate and configure for KF.
      '

  def banner
    say_status('info', 'Installing Hull Culture', :blue)
  end

  def install_sword
    # tmp, use fork and branch
    gem 'willow_sword', git: 'https://github.com/anarchist-raccoons/willow_sword.git', branch: 'hull'
  
    Bundler.with_clean_env do
      run "bundle install"
    end
    route("mount WillowSword::Engine => '/sword'")
  end

  def run_generators
    # kingsf - must happen after hyku_leaf and dog_biscuits
    generate 'hull_culture:setup', "-f"

    # models - this inserts into config/initializers/hyrax.rb
    generate ' dog_biscuits:generate_all', "-f"

    # This comes after the work generators because it inserts into the model
    generate 'hull_culture:custom_models', "-f"

    # This comes after the work generators because it inserts into the locales
    generate 'hull_culture:locales_labels', "-f"
  end
  
  # todo initial stuff etc
   def rake_tasks
    rake('assets:precompile')
  end

  def initial_rake_tasks
    if options[:initial]
      rails_command 'db:migrate'
      rake('hyrax:default_admin_set:create')
      rake('hyrax:workflow:load')
      rake('hyrax:default_collection_types:create')
    end
  end
end
