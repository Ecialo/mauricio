defmodule Mauricio.News.Adapter.Panorama do
  @behaviour Mauricio.News.Adapter

  @news_selector "div.np-recent-posts-wrapper"
  @content_selector "div.np-post-content"
  @time_selector "div.np-post-meta span a time.published"
  @href_selector "h3 a"

  @div "div"
  @a "a"
  @h4 "h4"
  @ul "ul"
  @time "time"
  @datetime "datetime"
  @news_block "Лента новостей"

  def extract(opts) do
    url = opts[:url]
  end

  def transform(doc) do
    Floki.find(doc, @news_selector)
    |> collect()
  end

  def collect([
        {@div, _clases,
         [
           {@h4, _, [@news_block]},
           {@ul, _, posts}
         ]}
      ]) do
    Enum.map(posts, &extract_post/1)
  end

  def extract_post(post_struct) do
    content = Floki.find(post_struct, @content_selector)
    href = Floki.find(content, @href_selector)
    time = Floki.find(content, @time_selector)

    [{@a, [{_, link}], [headline]}] = href
    [{@time, [_class, {@datetime, dt}], _}] = time

    {dt, headline, link}
    # nil
  end
end
