require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "logger"

ENV["RACK_ENV"] = "test"

require "active_record"

# for debugging
# ActiveRecord::Base.logger = Logger.new(STDOUT)

# rails does this in activerecord/lib/active_record/railtie.rb
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.time_zone_aware_attributes = true

# migrations
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migration.create_table :patients do |t|
  t.string  :first_name
  t.string  :last_name
  t.date    :birth_date
  t.boolean :enabled
  t.integer :income
  t.float :latitude
  t.float :longitude
  t.string :document_id
  t.timestamps
end

class Patient < ActiveRecord::Base

  true_vault \
    fields: {
      first_name: { index: false },
      last_name: { index: true },
      birth_date:  { index: true },
      enabled: { index: false },
      income: { index: false },
      latitude: { index: true },
      longitude: { index: true },
      created_at: { index: true }
    }
end
