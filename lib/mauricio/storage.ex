defmodule Mauricio.Storage do
  alias Mauricio.CatChat.{Chat, Cat}
  alias Mauricio.News
  alias __MODULE__, as: Storage

  @name Storage

  @type fetch_reply(s) :: {:reply, {:ok, Chat.t()} | :error, s}
  @type headline_reply(s) :: {:reply, {:ok, {Cat.news_track(), News.headline()}}, s}
  @type status_reply(s) :: {:reply, :ok | :error, s}
  @type noreply(s) :: {:noreply, s}
  @type all_ids_reply(s) :: {:reply, [Chat.chat_id()], s}

  @callback handle_get_all_ids(GenServer.from(), any()) :: all_ids_reply(any())
  @callback handle_fetch(Chat.chat_id(), GenServer.from(), any()) :: fetch_reply(any())
  @callback handle_get_headline({News.news_source(), Cat.news_track()}, GenServer.from(), any()) ::
              headline_reply(any)
  @callback handle_put(Chat.t(), GenServer.from(), any()) :: status_reply(any())
  @callback handle_put_headlines([News.tagged_headline()], any()) ::
              noreply(any())
  @callback handle_flush(GenServer.from(), any()) :: status_reply(any())
  @callback handle_pop(Chat.chat_id(), GenServer.from(), any()) :: status_reply(any())
  @callback handle_save(Chat.chat_id(), GenServer.from(), any()) :: status_reply(any())

  @callback handle_put_async(Chat.t(), any()) :: noreply(any())
  @callback handle_pop_async(Chat.chat_id(), any()) :: noreply(any())
  @callback handle_save_async(Chat.chat_id(), any()) :: noreply(any())

  def name do
    @name
  end

  defmacro __using__(_opts) do
    quote do
      use GenServer
      alias Mauricio.Storage, as: BaseStorage

      @behaviour Mauricio.Storage

      @type all_ids_reply() :: BaseStorage.all_ids_reply(storage())
      @type fetch_reply() :: BaseStorage.fetch_reply(storage())
      @type headline_reply() :: BaseStorage.headline_reply(storage())
      @type status_reply() :: BaseStorage.status_reply(storage())
      @type noreply() :: BaseStorage.noreply(storage())

      def handle_call(:get_all_ids, from, storage) do
        handle_get_all_ids(from, storage)
      end

      def handle_call({:fetch, chat_id}, from, storage) do
        handle_fetch(chat_id, from, storage)
      end

      def handle_call({:put, chat}, from, storage) do
        handle_put(chat, from, storage)
      end

      def handle_call({:get_headline, type, track}, from, storage) do
        handle_get_headline(type, track, storage)
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

      def handle_cast({:put_headlines, headlines}, storage) do
        handle_put_headlines(headlines, storage)
      end

      def handle_cast({:pop, chat_id}, storage) do
        handle_pop_async(chat_id, storage)
      end

      def handle_cast({:save, chat_id}, storage) do
        handle_save_async(chat_id, storage)
      end

      defp from_self(), do: {self(), nil}

      def handle_put_async(chat, storage) do
        {:reply, :ok, ns} = handle_put(chat, from_self(), storage)
        {:noreply, ns}
      end

      def handle_pop_async(chat_id, storage) do
        {:reply, :ok, ns} = handle_pop(chat_id, from_self(), storage)
        {:noreply, ns}
      end

      def handle_save_async(chat_id, storage) do
        {:reply, :ok, ns} = handle_save(chat_id, from_self(), storage)
        {:noreply, ns}
      end

      defoverridable from_self: 0, handle_put_async: 2, handle_pop_async: 2, handle_save_async: 2
    end
  end

  @spec put(Chat.t(), GenServer.server()) :: :ok | :error
  def put(chat, storage \\ Storage) do
    GenServer.call(storage, {:put, chat})
  end

  def put_async(chat, storage \\ Storage) do
    GenServer.cast(storage, {:put, chat})
  end

  @spec get_all_ids(GenServer.server()) :: [Chat.chat_id()]
  def get_all_ids(storage \\ Storage) do
    GenServer.call(storage, :get_all_ids)
  end

  @spec fetch(Chat.chat_id(), GenServer.server()) :: {:ok, Chat.t()} | :error
  def fetch(chat_id, storage \\ Storage) do
    GenServer.call(storage, {:fetch, chat_id})
  end

  def flush(storage \\ Storage) do
    GenServer.call(storage, :flush)
  end

  def pop(chat_id, storage \\ Storage) do
    GenServer.cast(storage, {:pop, chat_id})
  end

  def put_headlines(headlines, storage \\ Storage) do
    GenServer.cast(storage, {:put_headlines, headlines})
  end

  @spec get_headline({News.news_source(), Cat.news_track()}, GenServer.server()) ::
          {Cat.news_track(), News.headline()}
  def get_headline(type, track, storage \\ Storage) do
    GenServer.call(storage, {:get_headline, type, track})
  end

  def save(_), do: :ok

  def encode_news_source(:panorama), do: 0
end
