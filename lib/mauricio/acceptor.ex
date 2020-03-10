defmodule Mauricio.Acceptor do
  # require Logger
  alias Mauricio.CatChat
  @behaviour :elli_handler

  @tg_token Application.get_env(:nadia, :token)

  @impl :elli_handler
  def handle(req, _callback_args) do
    handle(:elli_request.method(req), :elli_request.path(req), req)
  end

  defp handle(:POST, [@tg_token], req) do
    req
    |> :elli_request.body()
    |> Jason.decode!(keys: :atoms)
    |> List.wrap()
    |> Nadia.Parser.parse_result("getUpdates")
    |> hd()
    |> CatChat.process_update()

    {200, [], ""}
  end

  defp handle(:GET, ["ping"], _req) do
    {200, [], "pong"}
  end

  defp handle(_, _, _req) do
    {404, [], "Our princess is in another castle..."}
  end

  @impl :elli_handler
  def handle_event(_event, _args, _config), do: :ok

  def start_link(args) do
    :elli.start_link(
      port: args[:port],
      callback: __MODULE__,
      callback_args: args
    )
  end

  def tg_token do
    @tg_token
  end

  def set_webhook(host) do
    Nadia.set_webhook(url: "#{host}/#{@tg_token}")
  end
end
