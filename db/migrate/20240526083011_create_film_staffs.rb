class CreateFilmStaffs < ActiveRecord::Migration[7.0]
  def change
    create_table :fil_staffts do |t|
      t.references :film, null: false, foreign_key: true
      t.references :staff, foreign_key: true

      t.timestamps
    end
  end
end
