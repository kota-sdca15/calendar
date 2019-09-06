class CreateSamples < ActiveRecord::Migration[5.2]
  def change
    create_table :calendars do |t|
      t.text :name
      t.text :password
      t.text :password_digest
      t.boolean :lock, default: false
      t.timestamps null: false
    end
  end
end
