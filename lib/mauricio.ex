defmodule Mauricio do
  use Application

  alias Mauricio.Storage.{MongoStorage, MapStorage}

  def select_update_provider(provider_type) do
    case provider_type do
      :poller -> [{Mauricio.Poller, []}]
      :acceptor -> [{Mauricio.Acceptor, [port: 4000]}]
      nil -> []
    end
  end

  def select_storage(nil), do: [{MapStorage, nil}]

  def select_storage(storage_opts) do
    {storage_type, opts} = Keyword.pop(storage_opts, :type)

    case storage_type do
      :mongo -> [{MongoStorage, opts}]
      :map -> [{MapStorage, opts}]
      nil -> [{MapStorage, nil}]
    end
  end

  def start(_type, _args) do
    update_provider =
      Application.get_env(:mauricio, :update_provider)
      |> select_update_provider()

    storage =
      Application.get_env(:mauricio, :storage)
      |> select_storage()

    cat_chat = [{Mauricio.CatChat, []}]

    children =
      Enum.concat([
        storage,
        cat_chat,
        update_provider
      ])

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def start_phase(:setup_webhook, :normal, _args) do
    IO.puts("Start webhook")

    case {
      Application.get_env(:mauricio, :update_provider),
      Application.get_env(:mauricio, :url)
    } do
      {:acceptor, url} when not is_nil(url) ->
        Mauricio.Acceptor.set_webhook(url)

      {:poller, _} ->
        Nadia.delete_webhook()

      _anything_else ->
        :ok
    end
  end
end
