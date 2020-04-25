defmodule Mauricio.Storage.MongoStorage do
  use Mauricio.Storage
  alias __MODULE__, as: Storage

  @type storage() :: pid()
  @coll "chats"

  def init(opts) do
    Mongo.start_link(opts)
  end

  def start_link(arg \\ nil) do
    name = arg || Storage
    GenServer.start_link(Storage, nil, name: name)
  end

  @spec handle_fetch(Chat.chat_id(), GenServer.from(), storage()) :: fetch_reply()
  def handle_fetch(chat_id, _from, storage) do
    chat = case Mongo.find_one(storage, @coll, %{_id: chat_id}) do
      nil -> :error
      chat -> chat
    end
    {:reply, chat, storage}
  end

  @spec handle_put(Chat.t(), GenServer.from(), storage()) :: status_reply()
  def handle_put(chat, _from, storage) do
    {:ok, _} = Mongo.insert_one(storage, @coll, encode_chat(chat), upsert: true)
    {:reply, :ok, storage}
  end

  @spec handle_flush(GenServer.from(), storage()) :: status_reply()
  def handle_flush(_from, storage) do
    Mongo.drop_collection(storage, @coll)
    {:reply, :ok, storage}
  end

  @spec handle_pop(Chat.chat_id(), GenServer.from(), storage()) :: status_reply()
  def handle_pop(chat_id, _from, storage) do
    Mongo.delete_one(storage, @coll, %{_id: chat_id})
    {:reply, :ok, storage}
  end

  @spec handle_save(Chat.chat_id(), GenServer.from(), storage()) :: status_reply()
  def handle_save(_chat_id, _from, storage) do
    {:reply, :ok, storage}
  end

  @spec handle_put_async(Chat.t(), storage()) :: noreply()
  def handle_put_async(chat, storage) do
    {:reply, :ok, state} = handle_put(chat, from_self(), storage)
    {:noreply, state}
  end

  @spec handle_pop_async(Chat.chat_id(), storage()) :: noreply()
  def handle_pop_async(chat_id, storage) do
    {:reply, :ok, ns} = handle_pop(chat_id, from_self(), storage)
    {:noreply, ns}
  end

  @spec handle_save_async(Chat.chat_id(), storage()) :: noreply()
  def handle_save_async(_chat_id, storage) do
    {:noreply, storage}
  end

  defp from_self(), do: {self(), nil}

  @spec encode_chat(Chat.chat_id()) :: map()
  defp encode_chat(chat) do
    {chat_id, new_chat} = Map.pop(chat, :chat_id)
    Map.put(new_chat, :_id, chat_id)
  end
end
