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
  before_save :perform_uuid

  def perform_uuid
    self.thirdparty_infos['user_uuids'] = self.thirdparty_infos["identities"].map { |identity| identity["uuid"] }
  end

  def self.find_by_uuid(uuid)
    # SELECT * FROM users WHERE thirdparty_infos -> 'user_uuids' @> '["787e7fe5-e08f-4fd1-a761-a854ce41caa5"]';    
    u = User.find_by("thirdparty_infos -> 'user_uuids' @> ?", "[\"#{uuid}\"]")

    # for debugging
    raise "User not found" if u.nil?
    # return
    u
  end
end


# Current
# class User < ActiveRecord::Base
#   def self.find_by_uuid(uuid)
#       self.where("EXISTS (
#           SELECT 1
#           FROM jsonb_array_elements(thirdparty_infos->'identities') as identity
#           WHERE identity->>'uuid' = ?
#         )", uuid).take
#   end
# end


# Alternative 1
# class User < ActiveRecord::Base
#   before_save :perform_uuid

#   def perform_uuid
#     self.user_uuids = self.thirdparty_infos["identities"].map { |identity| identity["uuid"] }
#   end

#   def self.find_by_uuid(uuid)
#       self.where("? = ANY(user_uuids)", uuid).take
#   end
# end

#  Second Try
# class User < ActiveRecord::Base
#   def self.find_by_uuid(uuid)
#     # SELECT * FROM users WHERE thirdparty_infos @> '{"identities": [{"uuid": "656ff884-99e8-4624-95d4-50d3952d2c38"}]}';
#     u = User.find_by("thirdparty_infos @> ?", { identities: [{ uuid: uuid }] }.to_json)

#     # for debugging
#     raise "User not found" if u.nil?
#     # return
#     u
#   end
# end