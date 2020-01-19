defmodule Katex.Text do

  def get_text(key, opts \\ []) do
    source =
      case Application.get_env(:katex, :text)[key] do
        v when is_list(v) -> Enum.random(v)
        v -> v
      end

    EEx.eval_string(source, opts)
  end

end
