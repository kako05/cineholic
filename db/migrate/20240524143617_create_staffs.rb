class CreateStaffs < ActiveRecord::Migration[7.0]
  def change
    create_table :staffs do |t|
      t.string     :name
      t.string     :role
      t.string     :production
      t.string     :official_site
      t.timestamps 
    end
  end
end
