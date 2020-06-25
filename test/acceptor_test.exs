defmodule MauricioTest.Acceptor do
  use ExUnit.Case

  alias Mauricio.Acceptor
  alias Mauricio.CatChat.Chats

  setup_all do
    children = [{Mauricio.Acceptor, [port: 4001]}]
    assert {:ok, _server_pid} = Supervisor.start_link(children, strategy: :one_for_one)
    Chats.stop_all_chats()
    :ok
  end

  setup do
    {:ok, _} = :bookish_spork.start_server()
    on_exit(&:bookish_spork.stop_server/0)

    {:ok, %{}}
  end

  def start_req(url) do
    HTTPoison.post(
      url,
      File.read!("./test/test_data/start_update.json"),
      [{"content-type", "application/json"}]
    )
  end

  def stop_req(url) do
    HTTPoison.post(
      url,
      File.read!("./test/test_data/stop_update.json"),
      [{"content-type", "application/json"}]
    )
  end

  test "ping" do
    assert {:ok, resp} = HTTPoison.get("localhost:4001/ping")
    assert resp.status_code == 200
    assert resp.body == "pong"
  end

  test "start-stop chat" do
    url = "localhost:4001/#{Acceptor.tg_token}"
    assert {:ok, resp} = start_req(url)
    assert resp.status_code == 200
    assert DynamicSupervisor.count_children(Chats) == %{active: 1, specs: 1, supervisors: 0, workers: 1}

    assert {:ok, resp} = HTTPoison.post(
      url,
      File.read!("./test/test_data/hello_update.json"),
      [{"content-type", "application/json"}]
    )

    assert {:ok, resp} = stop_req(url)
    assert resp.status_code == 200
    assert DynamicSupervisor.count_children(Chats) == %{active: 0, specs: 0, supervisors: 0, workers: 0}
  end

  test "set webhook" do
    Acceptor.set_webhook([host: "localhost", port: 4001])
    {:ok, request} = :bookish_spork.capture_request()
    {:ok, request} = :bookish_spork.capture_request()
    url =
      request
      |> Map.fetch!(:body)
      |> URI.decode_query()
      |> Map.fetch!("url")

    assert {:ok, resp} = start_req(url)
    assert resp.status_code == 200
    assert DynamicSupervisor.count_children(Chats) == %{active: 1, specs: 1, supervisors: 0, workers: 1}

    assert {:ok, resp} = stop_req(url)
    assert resp.status_code == 200
    assert DynamicSupervisor.count_children(Chats) == %{active: 0, specs: 0, supervisors: 0, workers: 0}
  end



end
