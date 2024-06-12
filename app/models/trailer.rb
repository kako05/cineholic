class Trailer < ApplicationRecord
  has_many :film_trailers, dependent: :destroy
  has_many :films, through: :film_trailers
end
