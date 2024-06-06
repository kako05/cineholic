class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :nickname, presence: true

  has_many :comments
  has_many :likes
  has_many :like_films, through: :likes, source: :film
end
