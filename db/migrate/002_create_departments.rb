class CreateDepartments < ActiveRecord::Migration[6.1]
  def change
    create_table :departments do |t|
      t.references :parent, index: true, foreign_key: { to_table: :departments }, null: true
      t.integer    :lft, index: true
      t.integer    :rgt, index: true
      t.string     :name, null: false
      t.text       :background
      t.references :head, index: true, foreign_key: { to_table: :people }, null: true
      
      t.timestamps
    end
  end
end
