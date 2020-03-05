defmodule MauricioTest.Acceptor do
  use ExUnit.Case

  alias Mauricio.Acceptor
  alias Mauricio.CatChat.Chats
  alias MauricioTest.Helpers

  setup_all do
    assert {:ok, _server_pid} = Mauricio.Acceptor.start_link(port: 4001)
    :ok
  end

  setup do
    {:ok, _} = :bookish_spork.start_server()
    on_exit(&:bookish_spork.stop_server/0)

    {:ok, %{}}
  end

  test "ping" do
    assert {:ok, resp} = HTTPoison.get("localhost:4001/ping")
    assert resp.status_code == 200
    assert resp.body == "pong"
  end

  test "start chat" do
    assert {:ok, resp} = HTTPoison.post(
      "localhost:4001/#{Acceptor.tg_token}",
      File.read!("./test/test_data/start_update.json"),
      [{"content-type", "application/json"}]
    )
    assert resp.status_code == 200
    assert DynamicSupervisor.count_children(Chats) == %{active: 1, specs: 1, supervisors: 0, workers: 1}

    assert {:ok, resp} = HTTPoison.post(
      "localhost:4001/#{Acceptor.tg_token}",
      File.read!("./test/test_data/stop_update.json"),
      [{"content-type", "application/json"}]
    )
    assert DynamicSupervisor.count_children(Chats) == %{active: 0, specs: 0, supervisors: 0, workers: 0}

  end



end
