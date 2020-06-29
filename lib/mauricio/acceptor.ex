defmodule Mauricio.Acceptor do
  require Logger
  alias Mauricio.CatChat
  alias Nadia.Model.Update, as: NadiaUpdate
  alias Nadia.Model.Message, as: NadiaMessage
  alias Nadia.Model.Chat, as: NadiaChat
  alias Nadia.Model.User, as: NadiaUser

  @type unpacked_nadia_message :: %{
    chat: %{id: integer()},
    date: integer(),
    from: NadiaUser.t(),
    message_id: integer(),
    text: binary()
  }

  @type unpacked_nadia_update :: %{
    message: unpacked_nadia_message(),
    update_id: integer()
  }

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
    |> unpack_update_struct()
    |> CatChat.process_update(:sync)

    {200, [], ""}
  end

  defp handle(:GET, ["ping"], _req) do
    {200, [], "pong"}
  end

  defp handle(_, _, _req) do
    {404, [], "Our princess is in another castle..."}
  end

  @spec unpack_update_struct(NadiaUpdate.t()) :: Acceptor.unpacked_nadia_message()
  def unpack_update_struct(%NadiaUpdate{message: message, update_id: update_id}) when not is_nil(message) do
    %NadiaMessage{
      chat: %NadiaChat{id: chat_id},
      date: date,
      from: from,
      message_id: message_id,
      text: text
    } = message

    %{
      message: %{
        chat: %{id: chat_id},
        date: date,
        from: from,
        message_id: message_id,
        text: text
      },
      update_id: update_id
    }
  end

  def unpack_update_struct(update) do
    Logger.warn(inspect(update))
    %{message: nil}
  end

  @impl :elli_handler
  def handle_event(_event, _args, _config), do: :ok

  def start_link(args) do
    Logger.info("Start Acceptor")

    :elli.start_link(
      port: args[:port],
      callback: __MODULE__,
      callback_args: args
    )
  end

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {Mauricio.Acceptor, :start_link, [args]}
    }
  end

  def tg_token do
    @tg_token
  end

  def set_webhook(url) do
    host = url[:host]
    port = url[:port]
    hook = "#{host}:#{port}/#{@tg_token}"
    Logger.info("Hook url #{hook}")
    Nadia.delete_webhook()
    Nadia.set_webhook(url: hook)
  end
end
