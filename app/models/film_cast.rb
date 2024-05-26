class FilmCast < ApplicationRecord
  belongs_to :film
  belongs_to :cast
end
