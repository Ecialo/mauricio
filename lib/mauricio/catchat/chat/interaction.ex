defmodule Mauricio.CatChat.Chat.Interaction do
  require Logger

  alias Nadia.Model.Message, as: NadiaMessage
  alias Nadia.Model.User, as: NadiaUser

  alias Mauricio.CatChat.{Member, Cat}
  alias Mauricio.Text

  @hug_command "/hug"
  @pet_command "/pet"
  @lazy_command "/become_lazy"
  @annoying_command "/become_annoying"
  @add_to_feeder_command "/add_to_feeder"

  def process_message(
    %NadiaMessage{text: text, from: %NadiaUser{id: user_id} = nadia_user} = message,
    %{members: members} = state
  ) when not is_nil(text) do
    Logger.info("Message from user_id #{user_id} with text #{text}")

    {chat_member, new_member?} = case Map.get(members, user_id) do
      nil -> {Member.new(nadia_user), true}
      member -> {member, false}
    end

    update_by_command = handle_command(String.downcase(text), chat_member, state)
    update = case update_by_command do
      nil ->
        triggers = Text.find_triggers(text)
        handle_regular_message(message, triggers, chat_member, state)
      update -> update
    end

    if new_member? do
      case update do
        nil -> {nil, chat_member, nil}
        {su, nil, m} -> {su, chat_member, m}
        update -> update
      end
    else
      update
    end
  end

  def add_to_feeder(feeder, food, who) do
    new_food_message = Text.get_text(:food_to_feeder, who: who, new_food: food)
    feeder = :queue.in(food, feeder)
    feeder_size = :queue.len(feeder)
    if feeder_size > 5 do
      {{:value, old_food}, feeder} = :queue.out(feeder)
      overflow_message = Text.get_text(:feeder_overflow, old_food: old_food)
      result_message = Enum.join([new_food_message, "", overflow_message], "\n")

      {feeder, nil, result_message}
    else
      {feeder, nil, new_food_message}
    end
  end

  def handle_command(
    text,
    who,
    %{
      feeder: feeder,
      cat: cat
    }) do
    case text do
      @add_to_feeder_command<>rest ->
        food = case String.split(rest, " ", parts: 2) do
          [""] -> "ничего"
          [_, ""] -> "ничего"
          [food] -> food
          [_, food] -> food
        end
        add_to_feeder(feeder, food, who)
      @hug_command<>_rest -> Cat.hug(cat, who)
      @pet_command<>_rest -> Cat.pet(cat, who)
      @lazy_command<>_rest -> Cat.become_lazy(cat, who)
      @annoying_command<>_rest-> Cat.become_annoying(cat, who)
      _ -> nil
    end
  end

  def handle_regular_message(_message, triggers, who, %{cat: cat}) do
    Cat.react_to_triggers(cat, who, triggers)
  end

end
