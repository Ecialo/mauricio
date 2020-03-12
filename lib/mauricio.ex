defmodule Mauricio do
  use Application

  def start(_type, _args) do
    update_provider =
      case Application.get_env(:mauricio, :update_provider) do
        :poller -> [{Mauricio.Poller, []}]
        :acceptor -> [{Mauricio.Acceptor, [port: 4000]}]
        nil -> []
      end

    children = [
      {Mauricio.CatChat, []},
      {Mauricio.Storage, []}
      | update_provider
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def start_phase(:setup_webhook, :normal, _args) do
    IO.puts("Start webhook")
    case {
      Application.get_env(:mauricio, :update_provider),
      Application.get_env(:mauricio, :url)
    } do
      {:acceptor, url} when not is_nil(url) ->
        # Mauricio.Acceptor.set_webhook(url)
        :ok
      {:poller, _} -> Nadia.delete_webhook()
      _anything_else -> :ok
    end
  end

end
