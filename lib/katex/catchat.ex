defmodule Katex.CatChat.Chats do
  use DynamicSupervisor
  require Logger
  alias Katex.CatChat.Chat

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_chat(chat_id) do
    spec = Chat.child_spec(chat_id)
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_chat(chat_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, chat_pid)
  end

end


defmodule Katex.CatChat.Supervisor do
  use Supervisor
  alias Katex.CatChat.Chats, as: CatChats
  alias Katex.CatChat.Chat

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    registry_name = Chat.registry_name
    children = [
      {Registry, [keys: :unique, name: registry_name]},
      {Katex.CatChat.Chats, []}
    ]
    Supervisor.init(children, strategy: :one_for_all)
  end

  def get_chat(chat_id) do
    registry = Chat.registry_name
    # l_result = Registry.lookup(registry, chat_id)
    # IO.inspect(l_result)
    # Logger.log(:info, chardata_or_fun, metadata \\ [])
    case Registry.lookup(registry, chat_id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

  def start_chat(chat_id) do
    CatChats.start_chat(chat_id)
  end

  def stop_chat(chat_pid) do
    CatChats.stop_chat(chat_pid)
  end

  # def stop_chat(chat_id) do

  # end

end

defmodule Katex.CatChat do
  use GenServer

  require Logger

  alias Katex.CatChat.Supervisor, as: CatSup
  alias Nadia.Model.Update, as: NadiaUpdate
  alias Nadia.Model.Message, as: NadiaMessage
  alias Nadia.Model.Chat, as: NadiaChat

  @start_command "/start"
  @stop_command "/stop"

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    CatSup.start_link()
  end

  def handle_cast(
    {:rout_update, %NadiaUpdate{message: message}},
    catsup_pid
  ) do
    %NadiaMessage{chat: chat, text: text} = message
    %NadiaChat{id: chat_id} = chat

    Logger.log(:info, "Message from #{chat_id} with text #{text}")

    chat_pid = CatSup.get_chat(chat_id)
    Logger.log(:info, "Chat pid #{inspect(chat_pid)}")
    case {chat_pid, text} do
      {nil, @start_command<>_rest} ->
        Logger.log(:info, "Start chat #{chat_id} by command #{text}")
        CatSup.start_chat(chat_id)
      {chat_pid, @stop_command<>_rest} when not is_nil(chat_pid) ->
        Logger.log(:info, "Stop chat #{chat_id} with pid #{inspect(chat_pid)} by command #{text}")
        CatSup.stop_chat(chat_pid)
      {nil, _text} -> nil
      {chat_pid, _text} ->
        GenServer.cast(chat_pid, {:process_message, message})
    end

    {:noreply, catsup_pid}
  end

  def handle_cast(request, pid) do
    IO.inspect(request)
    {:noreply, pid}
  end

  def process_update(update) do
    GenServer.cast(__MODULE__, {:rout_update, update})
  end

end
