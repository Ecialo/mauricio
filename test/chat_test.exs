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

    # IO.inspect(Registry.select(Chat.registry_name(), [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}]))
    # IO.inspect(Registry.lookup(Chat.registry_name(), 1))

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
