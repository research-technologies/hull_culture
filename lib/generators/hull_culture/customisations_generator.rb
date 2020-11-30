# frozen_string_literal: true

class HullCulture::CustomisationsGenerator < Rails::Generators::Base
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
  
  def add_include_for_visibility
    vis_include = "    include Hyrax::VisibilityControllerBehavior\n"
    
    DogBiscuits.config.selected_models.each do | m |
      return if File.read("app/controllers/hyrax/#{m.underscore.pluralize}_controller.rb").include?(vis_include)
      inject_into_file "app/controllers/hyrax/#{m.underscore.pluralize}_controller.rb", after: "include Hyrax::WorksControllerBehavior\n" do
        vis_include
      end
    end
  end
  
  def add_routes_for_visibility
    vis_routes = %q(
  namespace :hyrax, path: :concern do
    concerns_to_route.each do |curation_concern_name|
      namespaced_resources curation_concern_name, only: [] do
        member do
          get :visibility
          post :visibility, to: "#{curation_concern_name}#update_visibility"
        end
      end
    end
  end
      )

   # return if File.read('config/routes.rb').include?(vis_routes)
    inject_into_file 'config/routes.rb', before: "\n  mount Riiif::Engine" do
      vis_routes
    end
  end
end
