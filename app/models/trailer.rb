class Trailer < ApplicationRecord
  has_many :film_trailers
  has_many :films, through: :film_trailers
end
