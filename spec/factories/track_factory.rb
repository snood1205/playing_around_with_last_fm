# frozen_string_literal: true

FactoryBot.define do
  factory :track do
    artist { Faker::Music.band }
    album { Faker::Music.album }
    name { Faker::Hipster.sentence }
    listened_at { Faker::Date.between(DateTime.new(2002, 3, 20), DateTime.now).to_datetime }
  end
end
