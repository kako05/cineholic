class Film < ApplicationRecord
  has_many :casts
  has_many :staffs

  validates :title, presence: true, uniqueness: true
end
