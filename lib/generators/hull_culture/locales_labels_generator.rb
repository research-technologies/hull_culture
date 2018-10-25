# frozen_string_literal: true

class HullCulture::LocalesLabelsGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  desc '
This generator adds label changes into config/locales/hyrax.en.yml.
      '

  def banner
    say_status('info', 'Configuring labels in hyrax.en.yml', :blue)
  end

  def update_hyrax_locale_labels
    locale = 'config/locales/hyrax.en.yml'
    locale_text = File.read('config/locales/hyrax.en.yml')

    # do find/replace here
  end
end
