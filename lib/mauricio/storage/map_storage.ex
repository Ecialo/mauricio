defmodule Mauricio.Storage.MapStorage do
  use Mauricio.Storage
  alias __MODULE__, as: Storage
  alias Mauricio.CatChat.Chat

  @type storage() :: %{optional(Chat.chat_id()) => Chat.t()}

  def init(_arg) do
    {:ok, %{}}
  end

  def start_link(arg \\ nil) do
    name = arg || Storage
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

  # defp from_self(), do: {self(), nil}
end
