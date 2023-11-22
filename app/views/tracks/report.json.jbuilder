# frozen_string_literal: true

json.array! @attrs do |attr|
  json.title attr
  json.array top_tag_base(@tracks, attr, @top_count) do |attribute, count|
    json.attribute attribute
    json.count count
  end
end
