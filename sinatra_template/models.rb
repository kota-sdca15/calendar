require 'bundler/setup'
Bundler.require

if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class Task < ActiveRecord::Base
  validates_presence_of :title
  belongs_to :calendar
end

class Calendar < ActiveRecord::Base
  has_secure_password
  # validates :name, format: {with: /¥\w*/ }
  has_many :user_calendars
  has_many :users, through: :user_calendars
  has_many :tasks
end

class User < ActiveRecord::Base
  has_secure_password
  has_many :user_calendars
  has_many :calendars, through: :user_calendars
end

class Users_Calendar < ActiveRecord::Base
  belongs_to :user
  belongs_to :calendar
end