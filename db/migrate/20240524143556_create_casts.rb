class CreateCasts < ActiveRecord::Migration[7.0]
  def change
    create_table :casts do |t|
      t.string     :name
      t.timestamps
    end
  end
end
