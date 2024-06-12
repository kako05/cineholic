class Cast < ApplicationRecord
  has_many :film_casts, dependent: :destroy
  has_many :films, through: :film_casts
end
