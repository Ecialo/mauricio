defmodule Mauricio.CatChat.Chat.Interaction do
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

    chat_member = case Map.get(members, user_id) do
      nil -> Member.new(nadia_user)
      member -> member
    end

    update_by_command = handle_command(String.downcase(text), chat_member, state)
    case update_by_command do
      nil ->
        triggers = Text.find_triggers(text)
        handle_regular_message(message, triggers, chat_member, state)
      update -> update
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

      {feeder, who, result_message}
    else
      {feeder, who, new_food_message}
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
        [_, food] = String.split(rest, " ", parts: 2)
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
