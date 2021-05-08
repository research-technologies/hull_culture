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
    properties = %w[Accuracy VesselName VesselType PhotoSize PhotoPerson] # matches name of concern so camelized

    models = %w[photograph] # matches file_name so underscore
    models.each do |m|
      file_text = File.read("app/models/#{m}.rb")
      properties.each do |p|
        next if file_text.include? p
        inject_into_file "app/models/#{m}.rb", after: 'WorkBehavior' do
          "\n  include DogBiscuits::#{p}"
        end
      end
    end

    #Add lat long which needs to be indexed but is part of the Geo concern so not required to be processed above
    properties = %w[Accuracy VesselName VesselType PhotoSize PhotoPerson LatLong RightsHolder GeonameId BibliographicCitation]

    # solr_doc
    properties.each do |p|
      solr_doc = "\n  attribute :#{p.underscore.downcase}, Solr::Array, solr_name('#{p.underscore.downcase}')\n"
      next if File.read('app/models/solr_document.rb').include? p.underscore.downcase
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

  def fix_riiif
    gsub_file 'config/initializers/riiif.rb', 'Riiif::HTTPFileResolver.new', 'Riiif::HttpFileResolver.new'
    id_decode = %q(id = URI.decode(id)
  )

   # return if File.read('config/routes.rb').include?(vis_routes)
    inject_into_file  'config/initializers/riiif.rb', before: 'fs_id = id.sub(/\A([^\/]*)\/.*/, \'\1\')' do
      id_decode
    end
  end

  def add_manifest_routes
    end_of_routes="  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html"

    manifest_routes=%q(  # Route for non-image (PDF) files in Universal Viewer manifests
  get '/manifest_file/:id', to: 'hyrax/file_sets#manifest_file'
  # Route for format specific manifests
  get '/concern/digital_archival_objects/:id/manifest/(/:manifest_type)', to: 'hyrax/digital_archival_objects#manifest'

)
    inject_into_file 'config/routes.rb', before: end_of_routes do
      manifest_routes
    end

    # Inject a controller ot override the manifest and allow for type based manifests
    manifest_override=%q(
    # Override Hyrax 2.9.3 manifest in WorksControllerBehavior
    # /concern/digital_archival_objects/:id(/:manifest_type)
    def manifest

      headers['Access-Control-Allow-Origin'] = '*'

      json = iiif_manifest_builder.manifest_for(presenter: iiif_manifest_presenter, manifest_type: params[:manifest_type])

      respond_to do |wants|
        wants.json { render json: json }
        wants.html { render json: json }
      end
    end
)
    inject_into_file 'app/controllers/hyrax/digital_archival_objects_controller.rb', after: "self.show_presenter = Hyrax::DigitalArchivalObjectPresenter\n" do
      manifest_override
    end
  end

  # Use custom version of atribute rows that will check [model]_nolist_properties config item
  def recreate_attribute_rows
    models = %w[photograph] # matches file_name so underscore
    models.each do |m|
      attributes_file = "app/views/hyrax/#{m.pluralize}/_attribute_rows.html.erb"
      copy_file '_attribute_rows.html.erb', attributes_file
    end
  end
end
