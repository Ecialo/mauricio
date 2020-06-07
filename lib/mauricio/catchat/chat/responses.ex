defmodule Mauricio.CatChat.Chat.Responses do
  import Mauricio.CatChat.Chat, only: [is_feeder: 1]
  alias Mauricio.CatChat.{Member, Cat, Chat}

  def process_responses([], state),
    do: state

  def process_responses([nil | rest], state),
    do: process_responses(rest, state)

  def process_responses([{nil, nil, nil} | rest], state),
    do: process_responses(rest, state)

  def process_responses(
        [{nil, %Member{id: id} = new_member, nil} | rest],
        %{members: members} = state
      ),
      do: process_responses(rest, %{state | members: Map.put(members, id, new_member)})

  def process_responses([{nil, new_members, nil} | rest], %{members: members} = state),
    do:
      process_responses(
        rest,
        %{state | members: Enum.into(new_members, members, &{&1.id, &1})}
      )

  def process_responses([{%Cat{} = cat, new_members, nil} | rest], state),
    do: process_responses([{nil, new_members, nil} | rest], %{state | cat: cat})

  def process_responses([{feeder, new_members, nil} | rest], state) when is_feeder(feeder),
    do: process_responses([{nil, new_members, nil} | rest], %{state | feeder: feeder})

  def process_responses([{su, nm, []} | rest], state),
    do: process_responses([{su, nm, nil} | rest], state)

  def process_responses(
        [{su, nm, [response | rest_responses]} | rest],
        %{chat_id: chat_id} = state
      ) do
    Chat.send_message(chat_id, response)
    process_responses([{su, nm, rest_responses} | rest], state)
  end

  def process_responses([{su, nm, response} | rest], state),
    do: process_responses([{su, nm, [response]} | rest], state)

  def process_responses(response, state) when not is_list(response),
    do: process_responses([response], state)
end
