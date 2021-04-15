
zen_string_literal: true

class StreetviewUrlRenderer < Hyrax::Renderers::AttributeRenderer
  def attribute_value_to_html(value)
    link_to "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{t("Google Streetview")}".html_safe, "#{value}", :target => "_blank"
  end
end
