defmodule Mauricio.News.Adapter do
  alias Mauricio.News

  @opaque internal() :: any()

  @callback extract(opts :: Keyword.t()) :: internal()
  @callback transform(internal()) :: [News.tagged_headline()]
end
