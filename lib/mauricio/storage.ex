defmodule Mauricio.Storage do
  alias Mauricio.CatChat.Chat
  alias __MODULE__, as: Storage

  @name Storage

  @type fetch_reply(s) :: {:reply, {:ok, Chat.t()} | :error, s}
  @type status_reply(s) :: {:reply, :ok | :error, s}
  @type noreply(s) :: {:noreply, s}

  @callback handle_fetch(Chat.chat_id(), pid(), any()) :: fetch_reply(any())
  @callback handle_put(Chat.t(), pid(), any()) :: status_reply(any())
  @callback handle_put_async(Chat.t(), any()) :: noreply(any())
  @callback handle_flush(pid(), any()) :: status_reply(any())
  @callback handle_pop(Chat.chat_id(), pid(), any()) :: status_reply(any())
  @callback handle_pop_async(Chat.chat_id(), any()) :: noreply(any())
  @callback handle_save(Chat.chat_id(), pid(), any()) :: status_reply(any())
  @callback handle_save_async(Chat.chat_id(), any()) :: noreply(any())

  def name do
    @name
  end

  defmacro __using__(_opts) do
    quote do
      use GenServer
      alias Mauricio.Storage, as: BaseStorage

      @behaviour Mauricio.Storage

      @type fetch_reply() :: BaseStorage.fetch_reply(storage())
      @type status_reply() :: BaseStorage.status_reply(storage())
      @type noreply() :: BaseStorage.noreply(storage())

      def handle_call({:fetch, chat_id}, from, storage) do
        handle_fetch(chat_id, from, storage)
      end

      def handle_call({:put, chat}, from, storage) do
        handle_put(chat, from, storage)
      end

      def handle_call(:flush, from, storage) do
        handle_flush(from, storage)
      end

      def handle_call({:save, chat_id}, from, storage) do
        handle_save(chat_id, from, storage)
      end

      def handle_call({:pop, chat_id}, from, storage) do
        handle_pop(chat_id, from, storage)
      end

      def handle_cast({:put, chat}, storage) do
        handle_put_async(chat, storage)
      end

      def handle_cast({:pop, chat_id}, storage) do
        handle_pop_async(chat_id, storage)
      end

      def handle_cast({:save, chat_id}, storage) do
        handle_save_async(chat_id, storage)
      end
    end
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

  def save(_), do: :ok
end
