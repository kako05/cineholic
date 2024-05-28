class CreateFilmTrailers < ActiveRecord::Migration[7.0]
  def change
    create_table :film_trailers do |t|
      t.references :film, null: false, foreign_key: true
      t.references :trailer, foreign_key: true
      t.timestamps
    end
  end
end
