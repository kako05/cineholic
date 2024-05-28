class CreateFilms < ActiveRecord::Migration[7.0]
  def change
    create_table :films do |t|
      t.text     :title, limit: 65535
      t.text     :description
      t.string   :release_date
      t.string   :poster_image_url
      t.string   :link
      t.timestamps
    end
    add_index :films, :title, unique: true, length: 191
  end
end