class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :nickname, presence: true

  has_many :comments
  has_many :likes
  has_many :like_films, through: :likes, source: :film

  def self.authenticate(email, password)
    user = find_by(email: email)
    return user if user&.valid_password?(password)
    nil
  end
end
