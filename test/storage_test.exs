defmodule MauricioTest.Storage do
  use ExUnit.Case

  alias Mauricio.{Storage, CatChat}
  alias MauricioTest.Helpers

  def sigil_t(ts, _opts) do
    String.to_integer(ts)
    |> DateTime.from_unix!()
  end

  setup do
    {:ok, _} = :bookish_spork.start_server()
    on_exit(&:bookish_spork.stop_server/0)
    Storage.flush()
  end

  test "preserve chats" do
    assert Storage.fetch(1) == :error

    CatChat.process_update(Helpers.start_update())
    assert Storage.fetch(1) == :error

    CatChat.process_update(Helpers.update_with_text(1, "Витёк"))
    {:ok, state} = Storage.fetch(1)
    assert state.cat.name == "Витёк"

    CatChat.process_update(Helpers.update_with_text(1, "Скушай котлетку"))
    {:ok, new_state} = Storage.fetch(1)
    assert new_state.cat.satiety == state.cat.satiety + 1

    CatChat.process_update(Helpers.stop_update())
    assert Storage.fetch(1) == :error
  end

  describe "headlines" do
    test "put-get" do
      headline = {~t(100), "aaa", "bbb"}
      tagged_headline = {:panorama, headline}

      time_track = {~t(99), ~t(50), ~t(50)}

      Storage.put_headlines([tagged_headline])
      Process.sleep(100)
      r = Storage.get_headline(:panorama, time_track)
      IO.inspect(r, label: "huyak")

      assert false
    end
  end
end
