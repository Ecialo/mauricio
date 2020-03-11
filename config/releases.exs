import Config

config :mauricio,
  server: true,
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443],
  cat_api_token: System.get_env("CAT_API_TOKEN"),
  dog_api_token: System.get_env("DOG_API_TOKEN")
