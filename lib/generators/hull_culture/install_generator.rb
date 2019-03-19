# frozen_string_literal: true

class HullCulture::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  class_option :noprecompile, type: :boolean, default: false
  class_option :nogenerate, type: :boolean, default: false

  desc '
  Install, generate and configure for KF.
      '

  def banner
    say_status('info', 'Installing Hull Culture', :blue)
    exit 0 if options[:nogenerate]
  end

  def install_sword
    # tmp, use fork and branch
    gem 'willow_sword', git: 'https://github.com/CottageLabs/willow_sword.git'

    Bundler.with_clean_env do
      run 'bundle install'
    end
    route("mount WillowSword::Engine => '/sword'")
  end

  def run_generators
    # kingsf - must happen after hyku_leaf and dog_biscuits
    generate 'hull_culture:setup', '-f'

    # models - this inserts into config/initializers/hyrax.rb
    generate ' dog_biscuits:generate_all', '-f'

    # This comes after the work generators because it inserts into the model
    generate 'hull_culture:customisations', '-f'

    # This comes after the work generators because it inserts into the locales
    generate 'hull_culture:locales_labels', '-f'
  end
  
  # Replace the catalog controller, we have too much customisation to use the 
  #   DB one
  def catalog_controller
    directory 'app/controllers/', 'app/controllers/'
  end
  
  # Update catalog controller
  def catalog_controller_update
    
    catalog = 'app/controllers/catalog_controller.rb'
    catalog_file = File.read('app/controllers/catalog_controller.rb')
    
    [
      'file_format',
      'mime_type', 
      'aip_format_label', 
      'aip_format_version', 
      'aip_format_registry_key', 
      'aip_normalization_date', 
      'aip_normalization_detail',
      'sip_format_label',
      'sip_format_version',
      'sip_format_registry_key',
      'part_of',
      'identifier',
      'title',
      'creator',
      'depositor',
      'date_uploaded'
      
    ].each do | prop | 
    
      injection = "      config.add_search_field('#{prop}') do |field|\n" \
                    "        solr_name = solr_name('#{prop}', :stored_searchable)\n" \
                    "        field.solr_local_parameters = {\n" \
                    "          qf: solr_name,\n" \
                    "          pf: solr_name\n" \
                    "        }\n" \
                    "      end\n" \
                    "\n"
  
        next if catalog_file.include? injection
        inject_into_file catalog, before: '    # "sort results by" select (pulldown)' do
          injection
        end
      end
  end
  
  def indexers
  
    identifier = %(
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['identifier_sim'] = object.identifier
    end
  end
    )
    
    ['digital_archival_object', 'package'].each do | obj |
      indexer = "app/indexers/#{obj}_indexer.rb"
      
      inject_into_file indexer, after: "# Uncomment this block if you want to add custom indexing behavior:\n" do
        identifier
      end unless File.read(indexer).include? identifier
    end
  end
  
  def solr_document
    inject_into_file 'app/models/solr_document.rb', after: "DogBiscuits::ExtendedSolrDocument\n" do 
      "  include ArchivematicaExtendedSolrDocument\n" 
    end unless File.read('app/models/solr_document.rb').include?('ArchivematicaExtendedSolrDocument')
  end

  def rake_tasks
    rake('assets:precompile') unless options[:noprecompile]
  end
end
