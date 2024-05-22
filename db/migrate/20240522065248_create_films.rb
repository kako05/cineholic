class CreateFilms < ActiveRecord::Migration[7.0]
  def change
    create_table :films do |t|
      t.string   :title
      t.text     :text
      t.datetime :release
      t.string   :firstcast
      t.string   :secondcast
      t.string   :thridcast
      t.string   :fourthrcast
      t.string   :fifthcast
      t.string   :director
      t.string   :camera
      t.string   :art
      t.string   :sound
      t.string   :producer
      t.string   :crew
      t.string   :secondcrew
      t.string   :thridcrew
      t.timestamps
    end
  end
end
