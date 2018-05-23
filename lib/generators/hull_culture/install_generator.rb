# frozen_string_literal: true

class HullCulture::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc '
  Install, generate and configure for KF.
      '

  def banner
    say_status('info', 'Installing Hull Culture', :blue)
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
end
