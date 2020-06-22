defmodule StateHolder do
  alias Nadia.Model.Update, as: NadiaUpdate
  alias Nadia.Model.Message, as: NadiaMessage
  alias Nadia.Model.Chat, as: NadiaChat
  alias Nadia.Model.User, as: NadiaUser

  def nadia_state do
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

  def map_state do
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
end

defmodule StateServer do
  use GenServer

  def init(state), do: {:ok, state}

  def start_link(state), do: GenServer.start_link(__MODULE__, state)

  def stop, do: GenServer.stop(__MODULE__)

  def get, do: GenServer.call(__MODULE__, {:read})
  def send(state), do: GenServer.cast(__MODULE__, {:send, state})

  def handle_call({:read}, _, state), do: {:reply, state, state}
  def handle_cast({:send, state}, _state), do: {:noreply, state}
end


Benchee.run(
  %{
    "Nadia update" => fn -> {
      fn ->
        state = StateServer.get()
        StateServer.send(state)
        StateServer.get()
      end,
      before_scenario: fn -> StateServer.start_link(StateHolder.nadia_state()) end,
      after_scenario: fn -> StateServer.stop() end
    }
    end,
    "Map update" => fn -> {
      fn ->
        state = StateServer.get()
        StateServer.send(state)
        StateServer.get()
      end,
      before_scenario: fn -> StateServer.start_link(StateHolder.map_state()) end,
      after_scenario: fn -> StateServer.stop() end
    }
    end
  },
  memory_time: 2
)
