class CreateStaffs < ActiveRecord::Migration[7.0]
  def change
    create_table :staffs do |t|
      t.string     :name
      t.string     :role
      t.text       :production, limit: 65555
      t.string     :official_site
      t.timestamps 
    end
    add_index :staffs, :production, length: 191

  end
end