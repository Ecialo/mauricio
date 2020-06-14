defmodule MauricioTest.Storage.MapStorage do
  use ExUnit.Case
  use PropCheck

  alias Mauricio.Storage
  alias Mauricio.Storage.MapStorage
  alias MauricioTest.TestData

  setup_all do
    {:ok, pid} = MapStorage.start_link(MapStorage)
    %{storage_pid: pid}
  end

  setup context do
    Storage.flush(context.storage_pid)
  end

  test "fetch failed", context do
    assert :error == Storage.fetch(1, context.storage_pid)
  end

  test "flush drops collection", context do
    some_chat = TestData.produce_some_chat()
    chat_id = some_chat.chat_id

    :ok = Storage.put(some_chat, context.storage_pid)
    {:ok, _} = Storage.fetch(chat_id, context.storage_pid)

    Storage.flush(context.storage_pid)

    assert :error == Storage.fetch(chat_id, context.storage_pid)
  end

  test "put then fetch", context do
    some_chat = TestData.produce_some_chat()
    chat_id = some_chat.chat_id
    :ok = Storage.put(some_chat, context.storage_pid)
    {:ok, fetched_chat} = Storage.fetch(chat_id, context.storage_pid)
    assert some_chat == fetched_chat
  end

  test "get all ids", context do
    some_chat = &TestData.produce_some_chat/0

    chats =
      [some_chat.(), some_chat.(), some_chat.(), some_chat.(), some_chat.()]
      |> Enum.uniq_by(& &1.chat_id)

    chat_ids = MapSet.new(chats, & &1.chat_id)

    Enum.each(chats, fn chat -> Storage.put(chat, context.storage_pid) end)
    retrieved_chat_ids = Storage.get_all_ids(context.storage_pid) |> MapSet.new()
    assert chat_ids == retrieved_chat_ids
  end

  test "put then pop", context do
    some_chat = TestData.produce_some_chat()
    chat_id = some_chat.chat_id
    :ok = Storage.put(some_chat, context.storage_pid)
    Storage.pop(chat_id, context.storage_pid)
    assert :error == Storage.fetch(chat_id, context.storage_pid)
  end

  test "update", context do
    some_chat = TestData.produce_some_chat()
    chat_id = some_chat.chat_id

    :ok = Storage.put(some_chat, context.storage_pid)
    new_old_chat = update_in(some_chat.cat.weight, &(&1 + 1))

    :ok = Storage.put(new_old_chat, context.storage_pid)
    {:ok, fetched_chat} = Storage.fetch(chat_id, context.storage_pid)

    assert fetched_chat == new_old_chat
  end
end
