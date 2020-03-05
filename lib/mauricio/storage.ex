defmodule Mauricio.Storage do
  use GenServer
  alias __MODULE__, as: Storage
  def init(_arg) do
    {:ok, %{}}
  end

  def start_link(arg) do
    GenServer.start_link(Storage, arg, name: Storage)
  end

  def handle_call({:fetch, chat_id}, _from, storage) do
    {:reply, Map.fetch(storage, chat_id), storage}
  end

  def handle_call({:put, %{chat_id: chat_id} = chat}, _from, storage) do
    {:reply, :ok, Map.put(storage, chat_id, chat)}
  end

  def handle_call(:flush, _from, _storage) do
    {:reply, :ok, %{}}
  end

  def handle_call({:pop, chat_id},_from, storage) do
    {_, ns} = Map.pop(storage, chat_id)
    {:reply, :ok, ns}
  end

  def handle_cast({:put, %{chat_id: chat_id} = chat}, storage) do
    {:noreply, Map.put(storage, chat_id, chat)}
  end

  def handle_cast({:pop, chat_id},_from, storage) do
    {_, ns} = Map.pop(storage, chat_id)
    {:noreply, ns}
  end

  def put(chat) do
    GenServer.call(Storage, {:put, chat})
  end

  def put_async(chat) do
    GenServer.cast(Storage, {:put, chat})
  end

  def fetch(chat_id) do
    GenServer.call(Storage, {:fetch, chat_id})
  end

  def flush() do
    GenServer.call(Storage, :flush)
  end

  def pop(chat_id) do
    GenServer.cast(Storage, {:pop, chat_id})
  end

end
