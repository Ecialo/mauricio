defmodule MauricioTest.Storage do
  use ExUnit.Case

  alias Mauricio.{Storage, CatChat}
  alias MauricioTest.Helpers

  def sigil_t(ts, _opts) do
    ts
    |> String.to_integer()
    |> Kernel.*(1000)
    |> DateTime.from_unix!(:millisecond)
  end

  def tag_all_with(headlines, tag) do
    Enum.map(headlines, &{tag, &1})
  end

  def default_time_track do
    {~t(990), ~t(500), ~t(500)}
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
      headline = {~t(1000), "aaa", "bbb"}
      tagged_headline = {:panorama, headline}

      time_track = default_time_track()

      Storage.put_headlines([tagged_headline])
      {headline, new_track} = Storage.get_headline(:panorama, time_track)

      assert headline == {"aaa", "bbb"}
      assert new_track == {~t(1000), ~t(500), ~t(500)}
    end

    test "put same twice" do
      headlines =
        [
          {~t(1000), "1", "1"}
        ]
        |> tag_all_with(:panorama)

      new_headlines =
        [
          {~t(1500), "1", "1"},
          {~t(1400), "4", "4"}
        ]
        |> tag_all_with(:panorama)

      time_track = default_time_track()

      Storage.put_headlines(headlines)
      Storage.put_headlines(new_headlines)

      {headline, new_track} = Storage.get_headline(:panorama, time_track)

      assert headline == {"4", "4"}
      assert new_track == {~t(1400), ~t(500), ~t(500)}
    end

    test "different topics does not affect each other" do
      panorama_headlines =
        [
          {~t(1000), "1", "1"}
        ]
        |> tag_all_with(:panorama)

      neuromeduza_headlines =
        [
          {~t(1500), "2", "2"}
        ]
        |> tag_all_with(:neuromeduza)

      time_track = default_time_track()

      Storage.put_headlines(panorama_headlines)
      Storage.put_headlines(neuromeduza_headlines)

      {headline, new_track} = Storage.get_headline(:panorama, time_track)
      assert headline == {"1", "1"}
      assert new_track == {~t(1000), ~t(500), ~t(500)}

      {headline, new_track} = Storage.get_headline(:neuromeduza, time_track)
      assert headline == {"2", "2"}
      assert new_track == {~t(1500), ~t(500), ~t(500)}
    end

    test "most latest" do
      panorama_headlines =
        [
          {~t(1000), "1", "1"},
          {~t(990), "2", "2"}
        ]
        |> tag_all_with(:panorama)

      time_track = {~t(500), ~t(500), ~t(500)}

      Storage.put_headlines(panorama_headlines)

      {headline, new_track} = Storage.get_headline(:panorama, time_track)
      assert headline == {"1", "1"}
      assert new_track == {~t(1000), ~t(500), ~t(500)}
    end

    test "extend backlog up" do
      panorama_headlines =
        [
          {~t(1000), "1", "1"},
          {~t(990), "2", "2"},
          {~t(400), "3", "3"}
        ]
        |> tag_all_with(:panorama)

      time_track = {~t(1000), ~t(500), ~t(500)}

      Storage.put_headlines(panorama_headlines)

      {headline, new_track} = Storage.get_headline(:panorama, time_track)
      assert headline == {"2", "2"}
      assert new_track == {~t(1000), ~t(990), ~t(500)}
    end

    test "extend backlog down" do
      panorama_headlines =
        [
          {~t(1000), "1", "1"},
          {~t(990), "2", "2"},
          {~t(400), "3", "3"}
        ]
        |> tag_all_with(:panorama)

      time_track = {~t(1000), ~t(990), ~t(500)}

      Storage.put_headlines(panorama_headlines)

      {headline, new_track} = Storage.get_headline(:panorama, time_track)
      assert headline == {"3", "3"}
      assert new_track == {~t(1000), ~t(990), ~t(400)}
    end

    test "no news" do
      panorama_headlines =
        [
          {~t(1000), "1", "1"},
          {~t(990), "2", "2"},
          {~t(400), "3", "3"}
        ]
        |> tag_all_with(:panorama)

      time_track = {~t(1000), ~t(990), ~t(400)}

      Storage.put_headlines(panorama_headlines)

      {headline, new_track} = Storage.get_headline(:panorama, time_track)
      assert headline == {"наступает холодная, пугающая пустота.", nil}
      assert new_track == {~t(1000), ~t(990), ~t(400)}
    end
  end
end
