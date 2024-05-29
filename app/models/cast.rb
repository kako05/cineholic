class Cast < ApplicationRecord
  has_many :film_casts
  has_many :films, through: :film_casts
end
