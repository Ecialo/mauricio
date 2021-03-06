defmodule Mauricio.News do
  alias Mauricio.Storage

  @type news_source() :: :panorama
  @type raw_dt :: String.t()
  @type headline :: {published :: raw_dt(), content :: String.t(), link :: String.t() | nil}

  def all_news_sources do
    [:panorama]
  end

  def collect(adapter, opts) do
    opts
    |> adapter.extract()
    |> adapter.transform()
    |> Storage.put_headlines()
  end
end
