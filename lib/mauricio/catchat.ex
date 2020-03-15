defmodule Mauricio.CatChat.Chats do
  use DynamicSupervisor
  require Logger
  alias Mauricio.CatChat.Chat

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
    GenServer.call(chat_pid, :stop)
  end

end


defmodule Mauricio.CatChat.Supervisor do
  use Supervisor
  alias Mauricio.CatChat.Chats, as: CatChats
  alias Mauricio.CatChat.Chat

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    registry_name = Chat.registry_name
    children = [
      {Registry, [keys: :unique, name: registry_name]},
      {Mauricio.CatChat.Chats, []}
    ]
    Supervisor.init(children, strategy: :one_for_all)
  end

  def get_chat(chat_id) do
    registry = Chat.registry_name
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

end

defmodule Mauricio.CatChat do
  use GenServer

  require Logger

  alias Mauricio.CatChat.Supervisor, as: CatSup
  alias Mauricio.Text
  alias Nadia.Model.Update, as: NadiaUpdate
  alias Nadia.Model.Message, as: NadiaMessage
  alias Nadia.Model.Chat, as: NadiaChat

  @start_command "/start"
  @stop_command "/stop"
  @help_command "/help"

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    CatSup.start_link()
  end

  def handle_update(%NadiaUpdate{message: message}, mode) do
    %NadiaMessage{chat: chat, text: text} = message
    %NadiaChat{id: chat_id} = chat

    Logger.log(:info, "Message from #{chat_id} with text #{text}")

    chat_pid = CatSup.get_chat(chat_id)
    Logger.log(:info, "Chat pid #{inspect(chat_pid)}")
    case {chat_pid, text} do
      {_, nil} -> :ok
      {nil, @start_command<>_rest} ->
        Logger.log(:info, "Start chat #{chat_id} by command #{text}")
        CatSup.start_chat(chat_id)
        :ok
      {_, @help_command<>_rest} ->
        Nadia.send_message(chat_id, Text.get_text(:help))
        :ok
      {chat_pid, @stop_command<>_rest} when not is_nil(chat_pid) ->
        Logger.log(:info, "Stop chat #{chat_id} with pid #{inspect(chat_pid)} by command #{text}")
        CatSup.stop_chat(chat_pid)
        :ok
      {nil, _text} -> :ok
      {chat_pid, _text} ->
        Logger.log(:info, "Found #{chat_id} with pid #{inspect(chat_pid)}")
        case mode do
          :sync -> chat_pid
          :async ->
            GenServer.cast(chat_pid, {:process_message, message})
            :ok
        end
    end
  end

  def handle_cast({:process_update, update}, catsup_pid) do
    handle_update(update, :async)
    {:noreply, catsup_pid}
  end

  def handle_call({:process_update, update}, _from, catsup_pid) do
    {:reply, handle_update(update, :sync), catsup_pid}
  end

  def process_update(update, mode \\ :sync)
  def process_update(update, :async),
    do: GenServer.cast(__MODULE__, {:process_update, update})
  def process_update(%NadiaUpdate{message: message} = update, :sync) do
    case GenServer.call(__MODULE__, {:process_update, update}) do
      :ok -> :ok
      chat_pid ->
        GenServer.call(chat_pid, {:process_message, message})
    end
  end

end
