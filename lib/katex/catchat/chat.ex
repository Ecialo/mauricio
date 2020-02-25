defmodule Katex.CatChat.Chat.Interaction do
  alias Nadia.Model.Message, as: NadiaMessage
  alias Nadia.Model.User, as: NadiaUser

  alias Katex.CatChat.{Member, Cat, Chat}
  alias Katex.Text

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

defmodule Katex.CatChat.Chat do
  use GenServer

  require Logger

  alias Nadia.Model.Message, as: NadiaMessage
  alias Nadia.Model.User, as: NadiaUser
  alias Katex.CatChat.{Member, Cat}
  alias Katex.CatChat.Chat.Interaction
  alias Katex.Text

  alias __MODULE__, as: Chat

  @type chat_id() :: integer
  @type message_id() :: integer
  @type response_entity() :: :cat | :dog | String.t
  @type response() :: response_entity | {response_entity, message_id}
  @type feeder() :: :queue.queue(String.t)
  @type state() ::
    chat_id
    | %{
        members: %{optional(integer) => Member.t},
        chat_id: chat_id,
        cat: Cat.t,
        feeder: feeder()
      }
  @type chat_update ::
    nil
    | {
        nil | feeder() | Cat.t,
        Member.t | [Member.t],
        nil | response | [response]
      }

  @catchat_registry Registry.CatChat

  defguardp is_feeder(feeder) when
    is_tuple(feeder) and is_list(elem(feeder, 0)) and is_list(elem(feeder, 1))

  # Client

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link([chat_id]) do
    Logger.log(:info, "Start for #{chat_id}")
    GenServer.start_link(__MODULE__, chat_id, name: get_name(chat_id))
  end

  def call(chat_id, request, timeout \\ 5000) do
    name = get_name(chat_id)
    GenServer.call(name, request, timeout)
  end

  def cast(chat_id, request) do
    name = get_name(chat_id)
    GenServer.cast(name, request)
  end

  # Server

  @spec init([...]) :: {:ok, state, {:continue, :start}}
  def init(chat_id) do
    Logger.log(:info, "Init for #{chat_id}")
    {:ok, chat_id, {:continue, :start}}
  end

  def handle_continue(:start, chat_id) do
    Logger.log(:info, "Continue Start for #{chat_id}")
    send_message(chat_id, Text.get_text(:start))
    {:noreply, chat_id}
  end

  @spec process_message(NadiaMessage.t, Chat.state) :: Chat.state
  def process_message(message, state) do
    responses = Interaction.process_message(message, state)
    process_responses(responses, state)
  end

  @spec process_responses([Chat.chat_update], Chat.state) :: Chat.state
  def process_responses([], state),
    do: state

  def process_responses([nil | rest], state),
    do: process_responses(rest, state)

  def process_responses([{nil, %Member{id: id} = new_member, nil} | rest], %{members: members} = state),
    do: process_responses(rest, %{state | members: Map.put(members, id, new_member)})

  def process_responses([{nil, new_members, nil} | rest], %{members: members} = state),
    do: process_responses(
      rest,
      %{state | members: Enum.into(new_members, members, &{&1.id, &1})}
    )

  def process_responses([{%Cat{} = cat, new_members, nil} | rest], state),
    do: process_responses([{nil, new_members, nil} | rest], %{state | cat: cat})

  def process_responses([{feeder, new_members, nil} | rest], state) when is_feeder(feeder),
    do: process_responses([{nil, new_members, nil} | rest], %{state | feeder: feeder})

  def process_responses([{su, nm, []} | rest], state),
    do: process_responses([{su, nm, nil} | rest], state)

  def process_responses([{su, nm, [response | rest_responses]} | rest], %{chat_id: chat_id} = state) do
    send_message(chat_id, response)
    process_responses([{su, nm, rest_responses} | rest], state)
  end

  def process_responses([{su, nm, response} | rest], state),
    do: process_responses([{su, nm, [response]} | rest], state)

  def process_responses(response, state) when not is_list(response),
    do: process_responses([response], state)

  def handle_cast({:process_message, message}, state) when is_map(state) do
    Logger.log(:info, "Handle regular")
    new_state = process_message(message, state)
    {:noreply, new_state}
  end

  def handle_cast({:process_message, %NadiaMessage{text: text} = message}, chat_id) do
    default_name = Application.get_env(:katex, :default_name)
    {name, key} = case text do
      nil -> {default_name, :noname_cat}
      "" -> {default_name, :noname_cat}
      name -> {name, :name_cat}
    end
    name = String.capitalize(name)
    state = new_state(chat_id, message, name)

    send_message(chat_id, Text.get_text(key, cat: state.cat))

    schedule(state, [:tire, :pine, :metabolic, :hungry])

    {:noreply, state}
  end

  def schedule(_state, []) do end
  def schedule(state, [event | rest]) do
    schedule(state, event)
    schedule(state, rest)
  end
  def schedule(%{cat: %Cat{laziness: laziness}}, event) do
    time = Application.get_env(:katex, :schedule)[event] * laziness # seconds
    Process.send_after(self(), event, time * 1000)
  end

  def handle_info(:tire, %{cat: cat, members: members} = state) do
    {_, who} = Enum.random(members)
    state = Cat.tire(cat, who) |> process_responses(state)
    {:noreply, state}
  end

  def handle_info(:pine, %{cat: cat, members: members} = state) do
    who = members |> get_active_members() |> Enum.random()
    state = Cat.pine(cat, who) |> process_responses(state)
    {:noreply, state}
  end

  def handle_info(:metabolic, state) do
    nil
  end

  def handle_info(:hungry, state) do
    nil
  end

  def terminate(:normal, %{chat_id: chat_id}) do
    send_message(chat_id, Text.get_text(:stop))
  end

  # Helpers

  def get_active_members(members) do
    satisfy? = fn {_id, %Member{participant?: p}} ->
      p
    end

    members
    |> Enum.filter(satisfy?)
    |> elem(1)
  end

  def child_spec(chat_id) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[chat_id]]},
      restart: :transient
    }
  end

  @spec new_state(chat_id, NadiaMessage.t, String.t) :: state
  def new_state(chat_id, %NadiaMessage{from: user}, cat_name) do
    cat = Cat.new(cat_name)

    members = %{
      user.id => Member.new(
        user.first_name,
        user.last_name,
        user.id,
        3,
        true
      )
    }

    %{
      members: members,
      cat: cat,
      chat_id: chat_id,
      feeder: :queue.new()
    }
  end

  def get_name(chat_id) do
    {:via, Registry, {@catchat_registry, chat_id}}
  end

  def registry_name do
    @catchat_registry
  end

  def send_message(chat_id, response, options \\ [])

  def send_message(chat_id, {response, message_id}, options),
    do: send_message(chat_id, response, options ++ [reply_to_message_id: message_id])

  def send_message(chat_id, pet, options) when pet in [:cat, :dog] do
    case PetAPI.get_random_pet(pet) do
      {url, :animated} -> Nadia.send_animation(chat_id, url, options)
      {url, :static} -> Nadia.send_photo(chat_id, url, options)
    end
  end

  def send_message(chat_id, text, options) do
    Nadia.send_message(chat_id, text, options ++ [parse_mode: :HTML])
  end

end
