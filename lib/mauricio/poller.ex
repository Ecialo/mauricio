defmodule Mauricio.Poller do
  use GenServer
  require Logger
  alias Mauricio.CatChat

  def start_link(_arg) do
    Logger.log(:info, "Started poller")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    schedule_poll()
    {:ok, 0}
  end

  def handle_info(:poll, offset) do
    new_offset = poll(offset)
    schedule_poll()
    {:noreply, new_offset + 1}
  end

  def schedule_poll do
    Process.send_after(self(), :poll, 60 * 10)
  end

  def poll(offset \\ 0) do
    process_messages(Nadia.get_updates([offset: offset]))
  end

  def process_messages({:ok, []}) do
    -1
  end

  def process_messages({:ok, results}) do
    results
    |> Enum.map(&process_message/1)
    |> List.last()
  end

  def process_message(%{update_id: update_id} = update) do
    Logger.log(:info, inspect(update))
    CatChat.process_update(update, :async)
    update_id
  end

end
