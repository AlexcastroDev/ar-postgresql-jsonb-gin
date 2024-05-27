require_relative 'user'
require 'csv'
require 'faker'
require 'pg'

class ThirdParty
  def self.get_infos
    { name: Faker::Name.name, identities: [ { email: "does not matter", uuid: Faker::Internet.uuid } ] }
  end
end

# Debugging
# ActiveRecord::Base.logger = Logger.new(STDOUT)

task :migrate do
  ActiveRecord::Schema.define do
    create_table :users, force: true do |t|
      t.string :full_name
      t.jsonb :thirdparty_infos, default: {}, null: false
      
      # thirdparty_infos->'identities' as identity WHERE identity->>'uuid' = ?
      t.index "((thirdparty_infos -> 'identities' -> 'uuid'::text))", name: "index_users_on_thirdparty_infos_identities_uuid"
    end
  end
end

task :import_csv do
  users = []
  # Ensure the CSV file exists
  file = 'seed.csv'
  unless File.exist?(file)
    raise "CSV file not found"
  end

  CSV.foreach(file, encoding: 'utf-8', headers: true, skip_blanks: true, col_sep: ',').with_index(1) do |row, index|
    user = { full_name: row['full_name'], thirdparty_infos: ThirdParty.get_infos }
    users << user
  end

  ActiveRecord::Base.transaction do
    users.each do |user|
      User.create!(user)
    end
  end

  # Inject custom UUID
  random_index = rand(users.length)
  custom_infos = { name: Faker::Name.name, identities: [ { email: "does not matter", uuid: "itachiuchihadekonoha" } ] }
  user = User.find(random_index)
  user.update_columns(thirdparty_infos: custom_infos, full_name: "renegado")
  
  puts "Inject user with uuid: itachiuchihadekonoha at index #{random_index}"
end
