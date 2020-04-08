defmodule MauricioTest.CatChat do
  use ExUnit.Case

  alias Mauricio.CatChat
  alias Mauricio.CatChat.{Chat, Chats}
  alias Mauricio.CatChat.Cat
  alias MauricioTest.Helpers
  alias Mauricio.Text

  setup do
    {:ok, _} = :bookish_spork.start_server()
    on_exit(&:bookish_spork.stop_server/0)

    {:ok, %{}}
  end

  test "create new chat then shutdown then again" do
    :ok = CatChat.process_update(Helpers.start_update)
    assert DynamicSupervisor.count_children(Chats) == %{active: 1, specs: 1, supervisors: 0, workers: 1}

    :ok = CatChat.process_update(Helpers.stop_update)
    assert DynamicSupervisor.count_children(Chats) == %{active: 0, specs: 0, supervisors: 0, workers: 0}

    :ok = CatChat.process_update(Helpers.start_update)
    assert DynamicSupervisor.count_children(Chats) == %{active: 1, specs: 1, supervisors: 0, workers: 1}

    :ok = CatChat.process_update(Helpers.stop_update)
    assert DynamicSupervisor.count_children(Chats) == %{active: 0, specs: 0, supervisors: 0, workers: 0}
  end

end


defmodule MauricioTest.CatChat.ResponseProcessing do
  use ExUnit.Case

  alias Mauricio.Text
  alias Mauricio.CatChat.{Cat, Chat}
  alias Mauricio.CatChat.Chat.Responses
  alias MauricioTest.Helpers

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
      |> Responses.process_responses(chat_state)
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
    %Cat{
      times_pet: times_pet,
      laziness: laziness
    } = state[:cat]


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

defmodule MauricioTest.CatChat.Interaction do
  use ExUnit.Case

  alias Mauricio.Storage
  alias Mauricio.CatChat
  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Chat.Interaction
  alias MauricioTest.Helpers

  setup do
    {:ok, _} = :bookish_spork.start_server()
    on_exit(&:bookish_spork.stop_server/0)
    on_exit(&Storage.flush/0)

    {:ok, %{}}
  end

  test "add to feeder" do
    member = Member.new("A", "B", 1, 1, true)
    s = %{cat: Cat.new("C"), feeder: :queue.new()}
    {f, nil, _m} = Interaction.handle_command("/add_to_feeder", member, s)
    assert {:value, "ничего"} == :queue.peek(f)
    {f, nil, _m} = Interaction.handle_command("/add_to_feeder еда", member, s)
    assert {:value, "еда"} == :queue.peek(f)
    {f, nil, _m} = Interaction.handle_command("/add_to_feeder ", member, s)
    assert {:value, "ничего"} == :queue.peek(f)
    {f, nil, _m} = Interaction.handle_command("/add_to_feederеда", member, s)
    assert {:value, "еда"} == :queue.peek(f)
  end

  test "multiuser chat" do
    :ok = CatChat.process_update(Helpers.start_update)
    :ok = CatChat.process_update(Helpers.update_with_text(1, "Валера"))

    second_member_message = Helpers.update_with_text(1, 2, "123")
    assert second_member_message.message.from.id == 2

    :ok = CatChat.process_update(second_member_message)
    {:ok, state} = Storage.fetch(1)
    assert state.members[1].participant?
    assert Map.has_key?(state.members, 2)
    assert state.members[2].participant?

    :ok = CatChat.process_update(Helpers.update_with_text(1, 2, "Брысь"))
    {:ok, state} = Storage.fetch(1)
    assert state.members[1].participant?
    assert not state.members[2].participant?

    :ok = CatChat.process_update(Helpers.stop_update)
  end

end
