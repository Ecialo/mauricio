import Config

config :nadia,
  base_url: "http://localhost:32002/"

config :mauricio,
  storage: [type: :mongo, url: "mongodb://localhost:27017/db-name"]
