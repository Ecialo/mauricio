import Config

config :nadia,
  base_url: "http://localhost:32002/"

config :mauricio,
  storage: [
    type: :mongo,
    url:
      "mongodb://" <>
        System.get_env("MONGODB_HOST", "localhost") <>
        ":" <> System.get_env("MONGODB_PORT", "27017") <> "/db-name"
  ],
  env: :test
