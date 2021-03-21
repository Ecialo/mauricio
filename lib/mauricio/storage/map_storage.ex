defmodule Mauricio.Storage.MapStorage do
  use Mauricio.Storage

  alias __MODULE__, as: Storage
  alias Mauricio.CatChat.Chat

  @type storage() :: %{optional(Chat.chat_id()) => Chat.t()}

  def init(_arg) do
    {:ok, %{}}
  end

  def start_link(arg \\ nil) do
    name = arg || BaseStorage.name()
    GenServer.start_link(Storage, nil, name: name)
  end

  @spec handle_get_all_ids(GenServer.from(), storage()) :: all_ids_reply()
  def handle_get_all_ids(_from, storage) do
    {:reply, Map.keys(storage), storage}
  end

  @spec handle_fetch(Chat.chat_id(), GenServer.from(), storage()) :: fetch_reply()
  def handle_fetch(chat_id, _from, storage) do
    {:reply, Map.fetch(storage, chat_id), storage}
  end

  @spec handle_put(Chat.t(), GenServer.from(), storage()) :: status_reply()
  def handle_put(%{chat_id: chat_id} = chat, _from, storage) do
    {:reply, :ok, Map.put(storage, chat_id, chat)}
  end

  @spec handle_flush(GenServer.from(), storage()) :: status_reply()
  def handle_flush(_from, _storage) do
    {:reply, :ok, %{}}
  end

  @spec handle_pop(Chat.chat_id(), GenServer.from(), storage()) :: status_reply()
  def handle_pop(chat_id, _from, storage) do
    {_, ns} = Map.pop(storage, chat_id)
    {:reply, :ok, ns}
  end

  @spec handle_save(Chat.chat_id(), GenServer.from(), storage()) :: status_reply()
  def handle_save(_chat_id, _from, storage) do
    {:reply, :ok, storage}
  end

  def handle_put_headlines(headlines, storage) do
  end

  def handle_get_headline(type, track, storage) do
  end
end
