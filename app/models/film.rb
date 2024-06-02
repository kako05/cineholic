class Film < ApplicationRecord
  has_many :film_casts
  has_many :casts, through: :film_casts
  has_many :film_trailers
  has_many :trailers, through: :film_trailers

  validates :title, presence: true, uniqueness: true
end
