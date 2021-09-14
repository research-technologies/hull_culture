#forzen_string_literal: true

class IsoToHumanRenderer < Hyrax::Renderers::AttributeRenderer
  def attribute_value_to_html(value)
    # Maybe there's a way to o this with one fell swoop of a regex?
    if m = value.match(/^(\/)(.+)$/)
      return "Before #{m[2]}"
    end
    if m = value.match(/^(.+)(\/)$/)
      return "After #{m[1]}"
    end
    if m = value.match(/^(.+)(\/)(.+)$/)
      return "Between #{m[1]} and #{m[3]}"
    end
    value
  end
end
