class UserCalendars < ActiveRecord::Migration[5.2]
  def change
    create_table :user_calendars do |t|
      t.references :user
      t.references :calendar
    end
    add_foreign_key :users, :calendars
  end
end
