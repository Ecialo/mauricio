alias Nadia.Model.Update, as: NadiaUpdate
alias Nadia.Model.Message, as: NadiaMessage
alias Nadia.Model.Chat, as: NadiaChat
alias Nadia.Model.User, as: NadiaUser

nadia_state = %NadiaUpdate{
  callback_query: nil,
  channel_post: nil,
  chosen_inline_result: nil,
  edited_message: nil,
  inline_query: nil,
  message: %NadiaMessage{
    audio: nil,
    caption: nil,
    channel_chat_created: nil,
    chat: %NadiaChat{
      first_name: "First Name",
      id: 1,
      last_name: "",
      photo: nil,
      title: nil,
      type: "private",
      username: "Username"
    },
    contact: nil,
    date: 1592821755,
    delete_chat_photo: nil,
    document: nil,
    edit_date: nil,
    entities: nil,
    forward_date: nil,
    forward_from: nil,
    forward_from_chat: nil,
    from: %NadiaUser{
      first_name: "First Name",
      id: 1,
      last_name: "",
      username: "Username"
    },
    group_chat_created: nil,
    left_chat_member: nil,
    location: nil,
    message_id: 123123,
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
    text: "",
    venue: nil,
    video: nil,
    voice: nil
  },
  update_id: 123123
}

map_state = %{
  message: %{
    chat: %{ id: 1 },
    date: 1592821755,
    from: %NadiaUser{
      first_name: "First Name",
      id: 1,
      last_name: "",
      username: "Username"
    },
    text: ""
  },
  update_id: 123123
}

Benchee.run(
  %{
    "Nadia update" => fn ->
      parent = self()
      spawn(fn -> send(parent, {:send, nadia_state}) end)
      receive do
        {:send, message} -> message
      end
    end,
    "Map update" => fn ->
      parent = self()
      spawn(fn -> send(parent, {:send, map_state}) end)
      receive do
        {:send, message} -> message
      end
    end
  },
  memory_time: 2
)
