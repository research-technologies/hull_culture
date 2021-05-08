#forzen_string_literal: true

class GeonamesUrlRenderer < Hyrax::Renderers::AttributeRenderer
  def attribute_value_to_html(value)
    if @options[:geoname_id]
      link_to "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{value}".html_safe, "https://www.geonames.org/#{@options[:geoname_id].first}", :target => "_blank"
    else
      auto_link(ERB::Util.h(value))
    end
  end
end
