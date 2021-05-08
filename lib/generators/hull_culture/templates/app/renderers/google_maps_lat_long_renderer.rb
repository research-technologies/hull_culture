#forzen_string_literal: true

class GoogleMapsLatLongRenderer < Hyrax::Renderers::AttributeRenderer
  include HullCultureHelper
  def attribute_value_to_html(value)
    lat, long = latlong(value)
######
# Official cross platform map display URL (satellite view, zoom, no pin)
#######
#    link_to "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{value}".html_safe, "https://www.google.com/maps/@?api=1&map_action=map&center=#{lat},#{long}&basemap=satellite&zoom=17", :target => "_blank"
#######
# Official cross platform search URL (no satellite view, no zoom, yes pin)
#######
#    link_to "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{value}".html_safe, "https://www.google.com/maps/search/?api=1&map_action=map&query=#{lat},#{long}", :target => "_blank"
#######
# Unofficial probably not-cross-platfrom URL that has satellite, zoom, pin, and a shole bunch of other options (adding output=embed will hide the side panel, but as the name suggests is intended for embeded maps and can only be use for embedded maps)
####### 
    link_to "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{value}".html_safe, "http://maps.google.com/maps?t=k&q=loc:#{lat}+#{long}&z=17", :target => "_blank"
  end
end
