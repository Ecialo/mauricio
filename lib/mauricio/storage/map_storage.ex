defmodule Mauricio.Storage.MapStorage do
  use Mauricio.Storage
  alias __MODULE__, as: Storage
  alias Mauricio.CatChat.Chat

  @type storage() :: %{optional(Chat.chat_id()) => Chat.t()}

  def init(_arg) do
    {:ok, %{}}
  end

  def start_link(arg) do
    GenServer.start_link(Storage, arg, name: Storage)
  end

  # def handle_call({:fetch, chat_id}, _from, storage) do
  #   {:reply, Map.fetch(storage, chat_id), storage}
  # end

  # def handle_call({:put, %{chat_id: chat_id} = chat}, _from, storage) do
  #   {:reply, :ok, Map.put(storage, chat_id, chat)}
  # end

  # def handle_call(:flush, _from, _storage) do
  #   {:reply, :ok, %{}}
  # end

  # def handle_call({:pop, chat_id},_from, storage) do
  #   {_, ns} = Map.pop(storage, chat_id)
  #   {:reply, :ok, ns}
  # end

  @spec handle_fetch(Chat.chat_id(), pid(), storage()) :: fetch_reply()
  def handle_fetch(chat_id, _from, storage) do
    {:reply, Map.fetch(storage, chat_id), storage}
  end

  @spec handle_put(Chat.t(), pid(), storage()) :: status_reply()
  def handle_put(%{chat_id: chat_id} = chat, _from, storage) do
    {:reply, :ok, Map.put(storage, chat_id, chat)}
  end

  @spec handle_put_async(Chat.t(), storage()) :: noreply()
  def handle_put_async(chat, storage) do
    {:reply, :ok, state} = handle_put(chat, self(), storage)
    {:noreply, state}
  end

  @spec handle_flush(pid(), storage()) :: status_reply()
  def handle_flush(_from, _storage) do
    {:reply, :ok, %{}}
  end

  @spec handle_pop(Chat.chat_id(), pid(), storage()) :: status_reply()
  def handle_pop(chat_id, _from, storage) do
    {_, ns} = Map.pop(storage, chat_id)
    {:reply, :ok, ns}
  end

  @spec handle_pop_async(any, any) :: noreply()
  def handle_pop_async(chat_id, storage) do
    {:reply, :ok, ns} = handle_pop(chat_id, self(), storage)
    {:noreply, ns}
  end

  def handle_save(chat_id, _from, storage) do
  end

  def handle_save_async(chat_id, storage) do
  end

  # def handle_cast({:put, %{chat_id: chat_id} = chat}, storage) do
  #   {:noreply, Map.put(storage, chat_id, chat)}
  # end

  # def handle_cast({:pop, chat_id}, storage) do
  #   {_, ns} = Map.pop(storage, chat_id)
  #   {:noreply, ns}
  # end
end
