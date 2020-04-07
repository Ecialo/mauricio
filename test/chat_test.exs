defmodule MauricioTest.Chat do
  use ExUnit.Case

  alias Mauricio.CatChat.{Chat, Cat}
  alias Mauricio.CatChat.Cat.State.{Sleep, WantCare}
  alias MauricioTest.Helpers
  alias Mauricio.Text
  alias Mauricio.Storage

  setup do
    {:ok, _} = :bookish_spork.start_server()
    on_exit(&:bookish_spork.stop_server/0)

    {:ok, %{}}
  end

  def chat_with_turbo_cat do
    state = Chat.new_state(1, Helpers.message_with_text(1, "Kus kus"), "Котик")
    put_in(state.cat.laziness, 0)
  end

  test "start chat sequence" do
    chat_id = 11
    m = fn text -> Helpers.message_with_text(chat_id, text) end

    {:noreply, state} = Chat.handle_continue(:start, chat_id)
    Helpers.assert_capture_expected_text(Text.get_text(:start))
    dialog = [
      {m.("крутой уокер "), "<i>Котeйке нравится имя Крутой Уокер</i>\n"}
    ]
    Helpers.assert_dialog(state, dialog)
    bad_dialog = [
      {m.(""), "<i>Котик решил, что будет зваться Мяурицио</i>\n"}
    ]
    %{cat: %Cat{name: name}} = Helpers.assert_dialog(state, bad_dialog)
    assert name == Application.get_env(:mauricio, :default_name)
  end

  test "handle tire" do
    state = put_in(chat_with_turbo_cat().cat.energy, 0)
    {:noreply, new_state} = Chat.handle_info(:tire, state)

    assert new_state.cat.state == Sleep.new
    Helpers.assert_capture_expected_text(:any)
    assert_receive :tire
  end

  test "handle pine want care" do
    state = chat_with_turbo_cat()
    {:noreply, new_state} = Chat.handle_info(:pine, state)
    assert new_state.cat.state == WantCare.new
    Helpers.assert_capture_expected_text(:any)
    assert_receive :pine
  end

  test "handle metabolic" do
    state = put_in(chat_with_turbo_cat().cat.satiety, 10)
    {:noreply, new_state} = Chat.handle_info(:metabolic, state)
    Helpers.assert_capture_expected_text("Котик толстеет")
    assert new_state.cat.satiety == 9
    assert new_state.cat.weight == state.cat.weight + 1
    assert_receive :metabolic
  end

  test "handle metabolic with stop" do
    state = put_in(chat_with_turbo_cat().cat.satiety, 0)
    state = put_in(state.cat.weight, 2)
    {:stop, :normal, new_state} = Chat.handle_info(:metabolic, state)

    assert new_state.cat.weight == 1
    refute_receive :metabolic

  end

  test "handle hungry" do
    state = put_in(chat_with_turbo_cat().feeder, :queue.from_list(["eda"]))
    {:noreply, new_state} = Chat.handle_info(:hungry, state)
    Helpers.assert_capture_expected_text(Text.get_text(:feeder_consume, cat: state.cat, food: "eda"))
    Helpers.assert_capture_expected_text(:any)
    assert new_state.cat.satiety == state.cat.satiety + 1
    assert_receive :hungry
  end

  test "handle continue stored" do
    state = chat_with_turbo_cat()
    Storage.put(state)
    {:noreply, start_state} = Chat.handle_continue(:start, 1)
    assert start_state == state
    for signal <- [:tire, :pine, :metabolic, :hungry] do
      assert_receive signal
    end
    Storage.pop(1)
  end

end
