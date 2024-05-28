class FilmTrailer < ApplicationRecord
  belongs_to :film
  belongs_to :trailer
end
