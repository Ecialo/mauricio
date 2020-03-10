defmodule Mauricio.CatChat.Chat do
  use GenServer

  require Logger

  alias Nadia.Model.Message, as: NadiaMessage
  alias Mauricio.CatChat.{Member, Cat}
  alias Mauricio.CatChat.Chat.{Interaction, Responses}
  alias Mauricio.Text
  alias Mauricio.Storage

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
        nil | Member.t | [Member.t],
        nil | response | [response]
      }

  @catchat_registry Registry.CatChat

  defguard is_feeder(feeder) when
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
    case Storage.fetch(chat_id) do
      {:ok, chat} -> {:noreply, chat}
      :error ->
        send_message(chat_id, Text.get_text(:start))
        {:noreply, chat_id}
    end
  end

  def handle_call(:stop, _from, state) do
    # Logger.log(:info, "stop")
    {:stop, :normal, :ok, state}
  end

  def terminate(:normal, %{chat_id: chat_id}) do
    Storage.pop(chat_id)
    send_message(chat_id, Text.get_text(:stop))
  end
  def terminate(:normal, _state), do: nil

  @spec process_message(NadiaMessage.t, Chat.state) :: Chat.state
  def process_message(message, state) do
    responses = Interaction.process_message(message, state)
    Responses.process_responses(responses, state)
  end

  def handle_cast({:process_message, message}, state) when is_map(state) do
    Logger.log(:info, "Handle regular")
    new_state = process_message(message, state)
    {:noreply, new_state}
  end

  def handle_cast({:process_message, %NadiaMessage{text: text} = message}, chat_id) do
    default_name = Application.get_env(:mauricio, :default_name)
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
    time = Application.get_env(:mauricio, :schedule)[event] * laziness # seconds
    Process.send_after(self(), event, time * 1000)
  end

  def handle_info(:tire, %{cat: cat, members: members} = state) do
    {_, who} = Enum.random(members)
    state = Cat.tire(cat, who) |> Responses.process_responses(state)
    schedule(state, :tire)
    {:noreply, state}
  end

  def handle_info(:pine, %{cat: cat, members: members} = state) do
    {_, who} = Enum.random(members)
    state = Cat.pine(cat, who) |> Responses.process_responses(state)
    schedule(state, :pine)
    {:noreply, state}
  end

  def handle_info(:metabolic, %{cat: cat, members: members} = state) do
    {_, who} = Enum.random(members)
    state = cat |> Cat.metabolic(who) |> Responses.process_responses(state)
    if state.cat.weight >= 2 do
      schedule(state, :metabolic)
      {:noreply, state}
    else
      {:stop, :normal, state}
    end
  end

  def handle_info(:hungry, %{cat: cat, feeder: feeder} = state) do
    state = cat |> Cat.hungry(feeder) |> Responses.process_responses(state)
    schedule(state, :hungry)
    {:noreply, state}
  end

  # Helpers

  def get_active_members(members) do
    satisfy? = fn {_id, %Member{participant?: p}} ->
      p
    end

    Enum.filter(members, satisfy?)
  end

  def child_spec(chat_id) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[chat_id]]},
      restart: :transient
    }
  end

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

