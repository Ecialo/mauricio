ExUnit.start()

defmodule MauricioTest.Helpers do

  import ExUnit.Assertions

  alias Nadia.Model.User, as: NadiaUser

  alias Mauricio.CatChat.Chat

  def start_update do
    update_with_text(1, "/start")
  end

  def stop_update do
    update_with_text(1, "/stop")
  end

  def update_with_text(chat_id, user_id \\ nil, text) do
    user_id = user_id || chat_id
    %{
      message: message_with_text(chat_id, user_id, text),
      update_id: 555290602
    }
  end

  def message_with_text(chat_id, user_id \\ nil, text) do
    user_id = user_id || chat_id
    %{
      chat: %{id: chat_id},
      date: 1578194118,
      from: user(user_id),
      message_id: 1030,
      text: text
    }
  end

  def user(user_id) do
    %NadiaUser{
      first_name: "Yaropolk_#{user_id}",
      id: user_id,
      last_name: "#{user_id}",
      username: "Zloe_Aloe_#{user_id}",
    }
  end

  def body_of_captured_request() do
    :bookish_spork.capture_request()
      |> elem(1)
      |> Map.fetch!(:body)
      |> URI.decode_query()
  end

  def weak_text_eq(text, :any) when is_binary(text), do: true
  def weak_text_eq(text, expected_texts) when is_list(expected_texts),
    do: Enum.any?(expected_texts, fn x -> x == text end)
  def weak_text_eq(text, expected_text), do: text == expected_text

  def assert_capture_expected_text(expected_text) do
    request_text =
      body_of_captured_request()
      |> Map.fetch!("text")
    assert weak_text_eq(request_text, expected_text)
  end

  def assert_capture_photo_or_animation() do
    body = body_of_captured_request()
    assert Map.has_key?(body, "photo") or Map.has_key?(body, "animation")
  end

  def assert_dialog(state, []) do
    state
  end

  def assert_dialog(state, [{message, response} | rest]) when not is_tuple(message) do
    assert_dialog(state, [{{:process_message, message}, response} | rest])
  end

  def assert_dialog(state, [{message, response} | rest]) do
    {:noreply, new_state} = Chat.handle_cast(message, state)
    assert_capture_expected_text(response)

    assert_dialog(new_state, rest)
  end

end
