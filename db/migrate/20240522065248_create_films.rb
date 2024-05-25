class CreateFilms < ActiveRecord::Migration[7.0]
  def change
    create_table :films do |t|
      t.string   :title
      t.text     :description
      t.integer  :release_year
      t.string   :poster_image_url
      t.string   :link
      t.timestamps
    end
  end
end
