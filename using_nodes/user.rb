require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  encoding: "unicode",
  database: "test",
  username: "postgres",
  password: "",
  host: "db",
)

class User < ActiveRecord::Base
  def self.find_by_uuid(uuid)
    # SELECT * FROM users WHERE thirdparty_infos->'identities' ? 'f32b7b63-8005-4f95-96c1-5186664fb5d2';
    u = User.find_by("thirdparty_infos->'identities' ? :uuid", uuid: uuid)

    # for debugging
    raise "User not found" if u.nil?
    # return
    u
  end
end
