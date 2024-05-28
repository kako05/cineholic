class CreateTrailers < ActiveRecord::Migration[7.0]
  def change
    create_table :trailers do |t|
      t.string     :name
      t.string     :role
      t.text       :production, limit: 65555
      t.string     :official_site
      t.text       :text
      t.timestamps 
    end
    add_index :trailers, :production, length: 191

  end
end