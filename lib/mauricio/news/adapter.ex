defmodule Mauricio.News.Adapter do
  alias Mauricio.News

  @opaque internal :: any()

  @callback extract(opts :: Keyword.t()) :: internal()
  @callback transform(internal()) :: [{News.news_source(), News.headline()}]
end
