defmodule Mauricio.Storage.MongoStorage do
  use Mauricio.Storage
  alias Mauricio.Storage.{Serializable, Decoder}
  alias __MODULE__, as: Storage

  @type storage() :: pid()
  @coll "chats"

  def init(opts) do
    Mongo.start_link(opts)
  end

  def start_link(opts \\ [], name \\ nil) do
    name = name || Storage
    GenServer.start_link(Storage, opts, name: name)
  end

  @spec handle_get_all_ids(GenServer.from(), storage()) :: all_ids_reply()
  def handle_get_all_ids(_from, storage) do
    result =
      Mongo.find(storage, @coll, %{}, projection: %{"chat_id" => 1, "_id" => 0})
      |> Enum.map(&(&1["chat_id"]))
    {:reply, result, storage}
  end

  @spec handle_fetch(Chat.chat_id(), GenServer.from(), storage()) :: fetch_reply()
  def handle_fetch(chat_id, _from, storage) do
    chat = case Mongo.find_one(storage, @coll, %{_id: chat_id}) do
      nil -> :error
      chat -> {:ok, Decoder.decode(chat)}
    end
    {:reply, chat, storage}
  end

  @spec handle_put(Chat.t(), GenServer.from(), storage()) :: status_reply()
  def handle_put(chat, _from, storage) do
    s_chat = Serializable.encode(chat)
    {:ok, _} = Mongo.insert_one(storage, @coll, s_chat, upsert: true)
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
end
