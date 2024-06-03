class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :film

  validates :comment, presence: true
end