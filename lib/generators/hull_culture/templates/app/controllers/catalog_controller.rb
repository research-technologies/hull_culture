# frozen_string_literal: true
class CatalogController < ApplicationController
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior

  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show

  def self.uploaded_field
    solr_name('system_create', :stored_sortable, type: :date)
  end

  def self.modified_field
    solr_name('system_modified', :stored_sortable, type: :date)
  end

  configure_blacklight do |config|
    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    config.search_builder_class = HullCultureCatalogSearchBuilder

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: "search",
      rows: 10,
      qf: "title description creator keyword"
    }

    # Specify which field to use in the tag cloud on the homepage.
    # To disable the tag cloud, comment out this line.
    config.tag_cloud_field_name = Solrizer.solr_name("keyword", :facetable)

    # solr field configuration for document/show views
    config.index.title_field = solr_name("title", :stored_searchable)
    config.index.display_type_field = solr_name("has_model", :symbol)
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # replace facets start
    config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 5
    config.add_facet_field solr_name('packaged_by_titles', :facetable), limit: 5, label: 'In package'
    config.add_facet_field solr_name('identifier', :facetable), limit: 5, label: 'Accession Number'
    config.add_facet_field solr_name('part_of', :facetable), limit: 5, label: 'Collection'
    config.add_facet_field solr_name('extent', :facetable), limit: 5, label: 'Extent'
    config.add_facet_field solr_name('date_uploaded', :facetable), limit: 5
    # replace facets end

    config.add_facet_field solr_name("mime_type", :facetable), limit: 5, label: 'Mime type (DIP)'
    config.add_facet_field solr_name("format_label", :facetable), limit: 5, label: 'Format (DIP)'
    
    config.add_facet_field solr_name("aip_format_label", :facetable), limit: 5, label: 'Format (AIP)'
    config.add_facet_field solr_name("aip_format_registry_key", :facetable), limit: 5, label: 'Pronom key (AIP)'
    
    config.add_facet_field solr_name("sip_format_label", :facetable), limit: 5, label: 'Format (SIP)'
    config.add_facet_field solr_name("sip_format_registry_key", :facetable), limit: 5, label: 'Pronom key (SIP)'
    
    config.add_facet_field solr_name('member_of_collections', :symbol), limit: 5, label: 'Collections'

    # The generic_type isn't displayed on the facet list
    # It's used to give a label to the filter that comes from the user profile
    config.add_facet_field solr_name("generic_type", :facetable), if: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # insert indexes start
    config.add_index_field solr_name('title', :stored_searchable), if: false, itemprop:  'name', label:  'Title'
    config.add_index_field solr_name('date_uploaded', :stored_searchable), helper_method:  'human_readable_date'
    config.add_index_field solr_name('identifier', :stored_searchable), field_name: 'identifier', itemprop:  'identifier', label:  'Accession Number', helper_method:  'index_field_link'
    config.add_index_field solr_name('part_of', :stored_searchable), itemprop:  'isPartOf', label:  'Collection'
    config.add_index_field solr_name('extent', :stored_searchable), label:  'Extent'
    # insert indexes end
    
    config.add_index_field solr_name("format_label", :stored_searchable), label: 'Format (DIP)'
    config.add_index_field solr_name("aip_format_label", :stored_searchable), label: 'Format (AIP)'
    config.add_index_field solr_name("sip_format_label", :stored_searchable), label: 'Format (SIP)'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name("bit_depth", :stored_searchable)
    config.add_show_field solr_name("character_set", :stored_searchable)
    config.add_show_field solr_name("color_map", :stored_searchable)
    config.add_show_field solr_name("color_space", :stored_searchable)
    config.add_show_field solr_name("data_format", :stored_searchable)
    config.add_show_field solr_name("date_created", :stored_searchable)
    config.add_show_field solr_name("format_label", :stored_searchable)
    config.add_show_field solr_name("gps_timestamp", :stored_searchable)
    config.add_show_field solr_name("image_producer", :stored_searchable)
    config.add_show_field solr_name("language", :stored_searchable)
    config.add_show_field solr_name("latitude", :stored_searchable)
    config.add_show_field solr_name("longitude", :stored_searchable)
    config.add_show_field solr_name("markup_basis", :stored_searchable)
    config.add_show_field solr_name("markup_language", :stored_searchable)
    config.add_show_field solr_name("mime_type", :stored_searchable)
    config.add_show_field solr_name("aip_format_label", :stored_searchable)
    config.add_show_field solr_name("aip_format_version", :stored_searchable)
    config.add_show_field solr_name("aip_format_registry_key", :stored_searchable)
    config.add_show_field solr_name("aip_format_registry_name", :stored_searchable)
    config.add_show_field solr_name("aip_original_checksum_algorithm", :stored_searchable)
    config.add_show_field solr_name("aip_original_checksum_originator", :stored_searchable)
    config.add_show_field solr_name("aip_normalization_date", :stored_searchable)
    config.add_show_field solr_name("aip_normalization_detail", :stored_searchable)
    config.add_show_field solr_name("sip_format_label", :stored_searchable)
    config.add_show_field solr_name("sip_format_version", :stored_searchable)
    config.add_show_field solr_name("sip_format_registry_key", :stored_searchable)
    config.add_show_field solr_name("sip_format_registry_name", :stored_searchable)

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = solr_name("title", :stored_searchable)
      field.solr_parameters = {
        qf: "#{all_names} file_format all_text_timv",
        pf: title_name.to_s
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

      config.add_search_field('file_format') do |field|
        solr_name = solr_name('file_format', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('mime_type') do |field|
        solr_name = solr_name('mime_type', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('aip_format_label') do |field|
        solr_name = solr_name('aip_format_label', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('aip_format_version') do |field|
        solr_name = solr_name('aip_format_version', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('aip_format_registry_key') do |field|
        solr_name = solr_name('aip_format_registry_key', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('aip_normalization_date') do |field|
        solr_name = solr_name('aip_normalization_date', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('aip_normalization_detail') do |field|
        solr_name = solr_name('aip_normalization_detail', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('sip_format_label') do |field|
        solr_name = solr_name('sip_format_label', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('sip_format_version') do |field|
        solr_name = solr_name('sip_format_version', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('sip_format_registry_key') do |field|
        solr_name = solr_name('sip_format_registry_key', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('part_of') do |field|
        solr_name = solr_name('part_of', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('identifier') do |field|
        solr_name = solr_name('identifier', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('title') do |field|
        solr_name = solr_name('title', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('creator') do |field|
        solr_name = solr_name('creator', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('depositor') do |field|
        solr_name = solr_name('depositor', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('date_uploaded') do |field|
        solr_name = solr_name('date_uploaded', :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: "relevance"
    config.add_sort_field "#{uploaded_field} desc", label: "date uploaded \u25BC"
    config.add_sort_field "#{uploaded_field} asc", label: "date uploaded \u25B2"
    config.add_sort_field "#{modified_field} desc", label: "date modified \u25BC"
    config.add_sort_field "#{modified_field} asc", label: "date modified \u25B2"

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    false
  end
end