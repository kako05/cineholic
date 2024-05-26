class CreateFilmCasts < ActiveRecord::Migration[7.0]
  def change
    create_table :film_casts do |t|
      t.references :film, null: false, foreign_key: true
      t.references :cast, foreign_key: true

      t.timestamps
    end
  end
end
