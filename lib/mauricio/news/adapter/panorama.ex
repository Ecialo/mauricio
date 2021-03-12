defmodule Mauricio.News.Adapter.Panorama do
  @behaviour Mauricio.News.Adapter

  @news_selector "div.news.big-previews, div.news.medium-previews, div.news.small-previews"
  @div "div"
  @a "a"
  @href "href"
  @headline_selector "div h3"
  @panorama_url "https://panorama.pub"

  def extract(_opts), do: HTTPoison.get(@panorama_url) |> transform()

  def transform(doc) do
    Floki.find(doc, @news_selector)
    |> collect()
  end

  defp collect(blocks) do
    do_collect(blocks, [])
  end

  defp do_collect([], result),
    do:
      result
      |> Enum.uniq_by(fn {_, link} -> link end)
      |> Enum.with_index()
      |> Enum.map(fn {{headline, link}, index} ->
        {Timex.now() |> Timex.shift(minutes: -index), headline, link}
      end)

  defp do_collect([block | tail], result) do
    {@div, _, block_posts} = block
    parsed_posts = block_posts |> Enum.map(&parse/1)
    do_collect(tail, result ++ parsed_posts)
  end

  defp parse(post) do
    {@a, [{@href, link}, _, _], _} = post
    [{_, _, [headline]}] = Floki.find(post, @headline_selector)
    {headline, Path.join(@panorama_url, link)}
  end
end
