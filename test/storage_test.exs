defmodule MauricioTest.Storage do
  use ExUnit.Case

  alias Mauricio.Storage
  alias Mauricio.CatChat
  alias MauricioTest.Helpers

  setup do
    {:ok, _} = :bookish_spork.start_server()
    on_exit(&:bookish_spork.stop_server/0)
    on_exit(&Storage.flush/0)
  end

  test "put get" do
    v = %{chat_id: 1, val: 2}
    :ok = Storage.put(v)
    {:ok, vv} = Storage.fetch(1)
    assert v == vv
  end

  test "get" do
    assert :error == Storage.fetch(1)
  end

  test "preserve chats" do
    assert Storage.fetch(1) == :error

    CatChat.process_update(Helpers.start_update)
    assert Storage.fetch(1) == :error

    CatChat.process_update(Helpers.update_with_text(1, "Витёк"))
    {:ok, state} = Storage.fetch(1)
    assert state.cat.name == "Витёк"

    CatChat.process_update(Helpers.update_with_text(1, "Скушай котлетку"))
    {:ok, new_state} = Storage.fetch(1)
    assert new_state.cat.satiety == state.cat.satiety + 1

    CatChat.process_update(Helpers.stop_update)
    assert Storage.fetch(1) == :error
  end

end
