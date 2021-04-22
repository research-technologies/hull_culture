#forzen_string_literal: true

class GoogleMapsLatLongRenderer < Hyrax::Renderers::AttributeRenderer
  include HullCultureHelper
  def attribute_value_to_html(value)
    lat, long = latlong(value)
    link_to "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{value}".html_safe, "https://www.google.com/maps/@?api=1&map_action=map&center=#{lat},#{long}&basemap=satellite&zoom=16", :target => "_blank"
  end
end
