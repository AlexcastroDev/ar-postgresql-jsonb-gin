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
        self.where("EXISTS (
            SELECT 1
            FROM jsonb_array_elements(thirdparty_infos->'identities') as identity
            WHERE identity->>'uuid' = ?
          )", uuid).take
    end
end

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