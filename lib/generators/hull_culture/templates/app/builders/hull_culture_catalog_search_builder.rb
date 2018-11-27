# in CatalogController:
#   config.search_builder_class = HullCultureCatalogSearchBuilder

class HullCultureCatalogSearchBuilder < Hyrax::CatalogSearchBuilder
    
    def models
      work_classes + collection_classes + [::FileSet]
    end

end