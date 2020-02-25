defmodule KatexTest.CatChat do
  use ExUnit.Case

  alias Katex.CatChat
  alias Katex.CatChat.Chat
  alias Katex.CatChat.Cat
  alias KatexTest.Helpers
  alias Katex.Text

  setup do
    {:ok, _} = :bookish_spork.start_server()
    on_exit(&:bookish_spork.stop_server/0)

    {:ok, %{}}
  end

  test "create new chat then shutdown" do
    {:noreply, nil} = CatChat.handle_cast({:rout_update, Helpers.start_update}, nil)
    assert Registry.count(Chat.registry_name) == 1

    {:noreply, nil} = CatChat.handle_cast({:rout_update, Helpers.stop_update}, nil)
    assert Registry.count(Chat.registry_name) == 0
  end

  test "start chat sequence" do
    chat_id = 11
    m = fn text -> Helpers.message_with_text(chat_id, text) end

    {:noreply, state} = Chat.handle_continue(:start, chat_id)
    Helpers.assert_capture_expected_text(Text.get_text(:start))
    dialog = [
      {m.("Chertik"), "<i>Котeйке нравится имя Chertik</i>\n"}
    ]
    Helpers.assert_dialog(state, dialog)
    bad_dialog = [
      {m.(""), "<i>Котик решил, что будет зваться Юппи</i>\n"}
    ]
    %{cat: %Cat{name: name}} = Helpers.assert_dialog(state, bad_dialog)
    assert name == Application.get_env(:katex, :default_name)
  end

end

defmodule KatexTest.CatChat.ResponseProcessing do
  use ExUnit.Case

  alias Katex.Text
  alias Katex.CatChat.{Cat, Member, Chat}
  alias KatexTest.Helpers

  setup do
    {:ok, _} = :bookish_spork.start_server()
    on_exit(&:bookish_spork.stop_server/0)

    {:ok, %{}}
  end

  test "process response from cat reation" do
    chat_state = Chat.new_state(1, Helpers.message_with_text(1, "1"), "Cat")
    who = chat_state[:members][1]
    cat = chat_state[:cat]
    cat_satiety = cat.satiety

    fast_trigger = fn trigger ->
      Cat.react_to_triggers(cat, who, [trigger])
      |> List.wrap()
      |> Chat.process_responses(chat_state)
    end

    st = fast_trigger.(:banish)
    Helpers.assert_capture_expected_text(Text.get_text(:banished, cat: cat, who: who))
    assert st[:members][who.id].participant? == false

    st = fast_trigger.(:eat)
    Helpers.assert_capture_expected_text(:any)
    assert st[:cat].satiety == cat_satiety + 1

    _st = fast_trigger.(:mew)
    Helpers.assert_capture_expected_text(:any)

    _st = fast_trigger.(:cat)
    Helpers.assert_capture_photo_or_animation()

  end

  test "process response from command" do
    state = Chat.new_state(1, Helpers.message_with_text(1, "1"), "Cat")
    who = state[:members][1]
    %Cat{
      times_pet: times_pet,
      laziness: laziness
    } = cat = state[:cat]


    message = fn text -> Helpers.message_with_text(1, text) end

    Chat.process_message(message.("/hug"), state)
    Helpers.assert_capture_expected_text(:any)

    st = Chat.process_message(message.("/pet"), state)
    Helpers.assert_capture_expected_text(:any)
    assert st[:cat].times_pet == times_pet + 1

    st = Chat.process_message(message.("/become_lazy"), state)
    Helpers.assert_capture_expected_text(:any)
    assert st[:cat].laziness == laziness * 2

    st = Chat.process_message(message.("/become_annoying"), state)
    Helpers.assert_capture_expected_text(:any)
    assert st[:cat].laziness == round(laziness / 2)
  end

end
