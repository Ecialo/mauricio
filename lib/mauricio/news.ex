defmodule Mauricio.News do
  use GenServer
  alias __MODULE__, as: News
  @type raw_dt :: String.t()
  @type headline :: {published :: raw_dt(), content :: String.t(), link :: String.t() | nil}

  defstruct all: MapSet.new(), queues: %{}

  def new() do
    %News{}
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:get_news, lower, upper}) do
  end
end
