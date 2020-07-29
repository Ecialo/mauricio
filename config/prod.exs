import Config

config :nadia,
  token: System.get_env("TG_TOKEN")

config :mauricio,
  update_provider: :acceptor
