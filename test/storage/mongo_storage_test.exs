defmodule MauricioTest.Storage.MongoStorage do
  use ExUnit.Case

  alias Mauricio.Storage
  alias Mauricio.Storage.MongoStorage

  setup_all do
    {:ok, pid} =
      MongoStorage.start_link([url: "mongodb://localhost:27017/db-name"], Storage.name())

    %{storage_pid: pid}
  end

  test "fetch failed" do
    assert :error == Storage.fetch(1)
  end

  test "put then fetch" do
    Storage.put()
  end
end
