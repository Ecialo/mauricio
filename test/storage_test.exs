defmodule MauricioTest.Storage do
  use ExUnit.Case
  alias Mauricio.Storage

  setup do
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

end
