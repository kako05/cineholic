class Film < ApplicationRecord
  has_many :film_casts
  has_many :casts, through: :film_casts
  has_many :film_staffs
  has_many :staffs, through: :film_staffs
  
  validates :title, presence: true, uniqueness: true
end
