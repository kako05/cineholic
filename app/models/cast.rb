class Cast < ApplicationRecord
  belongs_to :film

  validates :name, presence: true
end