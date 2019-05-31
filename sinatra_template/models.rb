require 'bundler/setup'
Bundler.require

if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class Task < ActiveRecord::Base
  validates_presence_of :name
end

class Calendar < ActiveRecord::Base
  has_secure_password
end