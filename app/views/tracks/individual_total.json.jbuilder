json.array! @attributes_minus_method do |attr|
  json.title attr
  json.array! instance_variable_get(:"@#{attr}") do |value, count|
    json.count count
    json.value value
  end
end
