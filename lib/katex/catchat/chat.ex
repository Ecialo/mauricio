defmodule Katex.CatChat.Chat do
  use GenServer

  require Logger

  alias Nadia.Model.Message, as: NadiaMessage
  alias Nadia.Model.User, as: NadiaUser
  alias Katex.CatChat.{Member, Cat}
  alias Katex.Text

  @type chat_id() :: integer
  @type state() ::
    chat_id
    | %{
        members: %{optional(integer) => Member.t()},
        chat_id: chat_id,
        cat: Cat.t,
        feeder: [String.t]
      }

  @catchat_registry Registry.CatChat

  @hug_command "/hug"
  @pet_command "/pet"
  @lazy_command "/get_lazy"
  @energetic_command "/get_energetic"
  @add_to_feeder_command "/add_to_feeder"

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

  def handle_cast(
    {
      :process_message,
      %NadiaMessage{text: text} = message
    },
    %{
      cat: cat = %Cat{state: state}
    }
  ) do
    text = String.downcase(text)
    # mew_triggers =
    # mew_triggered? = String.con
    chat_update = case text do
      @add_to_feeder_command<>_rest -> nil
      @hug_command<>_rest -> nil
      @pet_command<>_rest -> nil
      @lazy_command<>_rest -> nil
      @energetic_command<>_rest->nil
      _ -> nil
    end
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

    {:noreply, state}
  end

  def terminate(:normal, %{chat_id: chat_id}) do
    send_message(chat_id, Text.get_text(:stop))
  end

  # Helpers

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
        user.id
      )
    }

    %{
      members: members,
      cat: cat,
      chat_id: chat_id,
      feeder: []
    }
  end

  def get_name(chat_id) do
    {:via, Registry, {@catchat_registry, chat_id}}
  end

  def registry_name do
    @catchat_registry
  end

  @spec send_message(chat_id, binary, keyword) ::
          {:error, Nadia.Model.Error.t()} | {:ok, Nadia.Model.Message.t()}
  def send_message(chat_id, text, options \\ []) do
    Nadia.send_message(chat_id, text, options ++ [parse_mode: :HTML])
  end


end
