FactoryBot.define do
  factory :film do
    title { Faker::Movie.title }
    description { Faker::Lorem.paragraph }
    release_date { Faker::Date.between(from: 1.year.ago, to: Date.today) }
    poster_image_url { Faker::Internet.url }
    link { Faker::Internet.url }
  end
end
