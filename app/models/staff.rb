class Staff < ApplicationRecord
  has_many :film_staffs
  has_many :films, through: :film_staffs

end