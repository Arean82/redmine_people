class AppendUserFields < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.string  :phone
      t.string  :address
      t.string  :skype
      t.date    :birthday
      t.string  :job_title
      t.string  :company
      t.string  :middlename
      t.integer :gender, limit: 2
      t.string  :twitter
      t.string  :facebook
      t.string  :linkedin
      t.text    :background
      t.date    :appearance_date
      t.integer :department_id, index: true
    end
  end
end
