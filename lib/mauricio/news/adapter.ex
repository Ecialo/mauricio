defmodule Mauricio.News.Adapter do
  alias Mauricio.News
  @type internal_presentation(p) :: p

  @callback extract(url :: String.t(), opts :: Keyword.t()) :: internal_presentation(any())
  @callback transform(internal_presentation(any())) :: [News.headline()]
end
