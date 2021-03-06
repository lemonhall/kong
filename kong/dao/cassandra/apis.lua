local BaseDao = require "kong.dao.cassandra.base_dao"
local constants = require "kong.constants"

local SCHEMA = {
  id = { type = constants.DATABASE_TYPES.ID },
  name = { type = "string", required = true, unique = true, queryable = true },
  public_dns = { type = "string", required = true, unique = true, queryable = true,
                 regex = "(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])" },
  target_url = { type = "string", required = true },
  created_at = { type = constants.DATABASE_TYPES.TIMESTAMP }
}

local Apis = BaseDao:extend()

function Apis:new(properties)
  self._schema = SCHEMA
  self._queries = {
    insert = {
      args_keys = { "id", "name", "public_dns", "target_url", "created_at" },
      query = [[ INSERT INTO apis(id, name, public_dns, target_url, created_at)
                  VALUES(?, ?, ?, ?, ?); ]]
    },
    update = {
      args_keys = { "name", "public_dns", "target_url", "id" },
      query = [[ UPDATE apis SET name = ?, public_dns = ?, target_url = ? WHERE id = ?; ]]
    },
    select = {
      query = [[ SELECT * FROM apis %s; ]]
    },
    select_one = {
      args_keys = { "id" },
      query = [[ SELECT * FROM apis WHERE id = ?; ]]
    },
    delete = {
      args_keys = { "id" },
      query = [[ DELETE FROM apis WHERE id = ?; ]]
    },
    __unique = {
      name = {
        args_keys = { "name" },
        query = [[ SELECT id FROM apis WHERE name = ?; ]]
      },
      public_dns = {
        args_keys = { "public_dns" },
        query = [[ SELECT id FROM apis WHERE public_dns = ?; ]]
      }
    }
  }

  Apis.super.new(self, properties)
end

return Apis
