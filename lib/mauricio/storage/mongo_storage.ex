defmodule Mauricio.Storage.MongoStorage do
  use Bitwise
  use Mauricio.Storage

  alias Mauricio.Storage.{Serializable, Decoder}
  alias __MODULE__, as: Storage

  @type storage() :: pid()
  @coll "chats"
  @news "news"

  @devil_seed 666
  @mask String.duplicate(<<255>>, 12) |> :binary.decode_unsigned()

  def init(opts) do
    Mongo.start_link(opts)
  end

  def start_link(opts \\ []) do
    {name, opts} = Keyword.pop(opts, :name)

    name = name || BaseStorage.name()
    GenServer.start_link(Storage, opts, name: name)
  end

  @spec handle_get_all_ids(GenServer.from(), storage()) :: all_ids_reply()
  def handle_get_all_ids(_from, storage) do
    result =
      Mongo.find(storage, @coll, %{}, projection: %{"chat_id" => 1, "_id" => 0})
      |> Enum.map(& &1["chat_id"])

    {:reply, result, storage}
  end

  @spec handle_fetch(Chat.chat_id(), GenServer.from(), storage()) :: fetch_reply()
  def handle_fetch(chat_id, _from, storage) do
    chat =
      case Mongo.find_one(storage, @coll, %{_id: chat_id}) do
        nil -> :error
        chat -> {:ok, Decoder.decode(chat)}
      end

    {:reply, chat, storage}
  end

  @spec handle_put(Chat.t(), GenServer.from(), storage()) :: status_reply()
  def handle_put(chat, _from, storage) do
    s_chat = Serializable.encode(chat)
    {:ok, _} = Mongo.replace_one(storage, @coll, %{"_id" => chat.chat_id}, s_chat, upsert: true)
    {:reply, :ok, storage}
  end

  @spec handle_flush(GenServer.from(), storage()) :: status_reply()
  def handle_flush(_from, storage) do
    Mongo.drop_collection(storage, @coll)
    Mongo.drop_collection(storage, @news)
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

  def handle_put_headlines(tagged_headlines, _from, storage) do
    headlines = Enum.map(tagged_headlines, &repack/1)

    Mongo.insert_many(storage, @news, headlines, ordered: false)
    |> IO.inspect()

    {:reply, :ok, storage}
  end

  def handle_get_headline(type, {last, backlog_n, backlog_o} = track, storage) do
    type = BaseStorage.encode_news_source(type)
    # match_type_stage = %{"$match" => %{"source" => %{"$eq" => type}}}
    # latest = %{}

    get_last = fn ->
      Mongo.find_one(
        storage,
        @news,
        %{"source" => %{"$eq" => type}, "posted_at" => %{"$gt" => last}},
        sort: %{"posted_at" => -1}
      )
      |> case do
        nil ->
          nil

        doc ->
          {important_parts(doc), {doc["posted_at"], backlog_n, backlog_o}}
      end
    end

    extend_backlog_up = fn ->
      Mongo.find_one(
        storage,
        @news,
        %{
          "source" => %{"$eq" => type},
          "posted_at" => %{
            "$gt" => backlog_n,
            "$lt" => last
          }
        },
        sort: %{"posted_at" => 1}
      )
      |> case do
        nil ->
          nil

        doc ->
          {important_parts(doc), {last, doc["posted_at"], backlog_o}}
      end
    end

    extend_backlog_down = fn ->
      Mongo.find_one(
        storage,
        @news,
        %{
          "source" => %{"$eq" => type},
          "posted_at" => %{
            "$lt" => backlog_o
          }
        },
        sort: %{"posted_at" => -1}
      )
      |> case do
        nil ->
          nil

        doc ->
          {important_parts(doc), {last, backlog_n, doc["posted_at"]}}
      end
    end

    headline_with_track =
      get_last.() ||
        extend_backlog_up.() ||
        extend_backlog_down.() ||
        {empty_news(), track}

    {:reply, headline_with_track, storage}
  end

  defp empty_news do
    {"наступает холодная, пугающая пустота.", nil}
  end

  defp important_parts(news) do
    {news["content"], news["link"]}
  end

  defp repack({news_source, {posted_at, content, link}}) do
    # id = BaseStorage.make_id(content)
    id =
      content
      |> Murmur.hash_x64_128(@devil_seed)
      |> band(@mask)
      |> :binary.encode_unsigned()

    %{
      "_id" => %BSON.ObjectId{value: id},
      "source" => BaseStorage.encode_news_source(news_source),
      "content" => content,
      "posted_at" => posted_at,
      "link" => link
    }
  end
end
