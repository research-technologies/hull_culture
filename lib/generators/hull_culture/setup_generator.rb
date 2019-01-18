# frozen_string_literal: true

class HullCulture::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  desc '
This generator adds Hull Culture Specific changes and configurations.
      '

  def banner
    say_status('info', 'Configuring for Hull Culture', :blue)
  end

  def create_configs
    directory 'config', 'config'
  end
  
  def create_app
    directory 'app', 'app'
  end

  def create_lib
    directory 'lib', 'lib'
  end
  
  def create_public
    directory 'public', 'lib'
  end

  def create_specs
    directory 'spec', 'spec'
  end
end
