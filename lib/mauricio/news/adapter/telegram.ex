defmodule Mauricio.News.Adapter.Telegram do
  @behaviour Mauricio.News.Adapter

  @news_selector "div.tgme_widget_message_text, span.tgme_widget_message_meta"

  def extract(opts) do
    url = opts[:url]
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(url)
    transform(body)
  end

  def transform(doc), do: Floki.find(doc, @news_selector) |> collect()

  defp collect(blocks), do: do_collect_blocks(blocks, [])

  defp do_collect_blocks([], result), do: result |> Enum.uniq() |> Enum.reverse()

  defp do_collect_blocks([headline_block, meta_block | tail], result) do
    {"div", _, [headline]} = headline_block
    {"span", _, [{"a", [_, {"href", link}], [{"time", [{"datetime", dt}, _], _}]}]} = meta_block

    do_collect_blocks(tail, [{Timex.parse!(dt, "{ISO:Extended}"), headline, link} | result])
  end
end
