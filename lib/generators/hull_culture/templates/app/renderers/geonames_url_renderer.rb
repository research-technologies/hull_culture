#forzen_string_literal: true

class GeonamesUrlRenderer < Hyrax::Renderers::AttributeRenderer
  def attribute_value_to_html(value)
    link_to "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{t("GeoNames")}".html_safe, "https://www.geonames.org/#{value}", :target => "_blank"
  end
end
