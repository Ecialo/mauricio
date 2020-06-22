defmodule StateHolder do
  alias Nadia.Model.Update, as: NadiaUpdate
  alias Nadia.Model.Message, as: NadiaMessage
  alias Nadia.Model.Chat, as: NadiaChat
  alias Nadia.Model.User, as: NadiaUser

  def initial_nadia_state do
    %NadiaUpdate{
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
  end

  def initial_map_state do
    %{
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
  end

  def update_nadia(%NadiaUpdate{message: message, update_id: update_id}, new_text) do
    %NadiaUpdate{message: %NadiaMessage{message | text: new_text}, update_id: update_id}
  end

  def update_map(%{message: message, update_id: update_id}, new_text) do
    %{message: %{message | text: new_text}, update_id: update_id}
  end
end

defmodule StateServer do
  use GenServer

  def init(state), do: {:ok, state}

  def start_link(state, name), do: GenServer.start_link(__MODULE__, state, name: name)

  def stop(name), do: GenServer.stop(name)

  def get(name), do: GenServer.call(name, {:read})
  def update_nadia(text), do: GenServer.cast(:nadia, {:update_nadia, text})
  def update_map(text), do: GenServer.cast(:map, {:update_map, text})

  def handle_call({:read}, _, state), do: {:reply, state, state}

  def handle_cast({:update_nadia, text}, state), do: {:noreply, StateHolder.update_nadia(state, text)}
  def handle_cast({:update_map, text}, state), do: {:noreply, StateHolder.update_map(state, text)}
end


Benchee.run(
  %{
    "Nadia update" => fn -> {
      fn -> Enum.each(1..100, fn i ->
          StateServer.update_nadia(to_string(i))
          StateServer.get(:nadia)
        end)
      end,
      before_scenario: fn -> StateServer.start_link(StateHolder.initial_nadia_state(), :nadia) end,
      after_scenario: fn -> StateServer.stop(:nadia) end
    }
    end,
    "Map update" => fn -> {
      fn -> Enum.each(1..100, fn i ->
          StateServer.update_map(to_string(i))
          StateServer.get(:map)
        end)
      end,
      before_scenario: fn -> StateServer.start_link(StateHolder.initial_map_state(), :map) end,
      after_scenario: fn -> StateServer.stop(:map) end
    }
    end
  },
  memory_time: 2
)
