class FilmStaff < ApplicationRecord
  belongs_to :film
  belongs_to :staff
end
