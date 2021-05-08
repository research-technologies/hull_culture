#forzen_string_literal: true

class SimpleFormatRenderer < Hyrax::Renderers::AttributeRenderer
  def attribute_value_to_html(value)
    simple_format(value)
  end
end
