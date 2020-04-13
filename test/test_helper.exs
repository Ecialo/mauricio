ExUnit.start()

defmodule MauricioTest.Helpers do

  import ExUnit.Assertions

  alias Nadia.Model.Update, as: NadiaUpdate
  alias Nadia.Model.Message, as: NadiaMessage
  alias Nadia.Model.Chat, as: NadiaChat
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
    %NadiaUpdate{
      callback_query: nil,
      channel_post: nil,
      chosen_inline_result: nil,
      edited_message: nil,
      inline_query: nil,
      message: message_with_text(chat_id, user_id, text),
      update_id: 555290602
    }
  end

  def message_with_text(chat_id, user_id \\ nil, text) do
    user_id = user_id || chat_id
    %NadiaMessage{
      audio: nil,
      caption: nil,
      channel_chat_created: nil,
      chat: chat(chat_id),
      contact: nil,
      date: 1578194118,
      delete_chat_photo: nil,
      document: nil,
      edit_date: nil,
      entities: nil,
      forward_date: nil,
      forward_from: nil,
      forward_from_chat: nil,
      from: user(user_id),
      group_chat_created: nil,
      left_chat_member: nil,
      location: nil,
      message_id: 1030,
      migrate_from_chat_id: nil,
      migrate_to_chat_id: nil,
      new_chat_member: nil,
      new_chat_photo: [],
      new_chat_title: nil,
      photo: [],
      pinned_message: nil,
      reply_to_message: nil,
      sticker: nil,
      supergroup_chat_created: nil,
      text: text,
      venue: nil,
      video: nil,
      voice: nil
    }
  end

  def chat(chat_id) do
    %NadiaChat{
      first_name: "Yaropolk",
      id: chat_id,
      last_name: "",
      photo: nil,
      title: nil,
      type: "private",
      username: "Zloe_Aloe",
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

  def assert_dialog(state, [{{_action, message_struct} = message, response} | rest]) do
    {:noreply, new_state} = Chat.handle_cast(message, state)
    body = body_of_captured_request()
    assert weak_text_eq(Map.fetch!(body, "text"), response)

    reply_to_message_id = body |> Map.fetch!("reply_to_message_id") |> String.to_integer()
    assert reply_to_message_id == message_struct.message_id

    assert_dialog(new_state, rest)
  end

end
