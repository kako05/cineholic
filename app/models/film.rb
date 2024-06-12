class Film < ApplicationRecord
  has_many :film_casts, dependent: :destroy
  has_many :casts, through: :film_casts
  has_many :film_trailers, dependent: :destroy
  has_many :trailers, through: :film_trailers
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user

  def liked_by?(user)
    likes.where(user_id: user.id).exists?
  end

  validates :title, presence: true, uniqueness: true
end
