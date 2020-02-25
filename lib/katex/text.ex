defmodule Katex.Text do

  @type trigger() ::
    :loud
    | :attract
    | :banish
    | :cat
    | :dog
    | :mew
    | :eat

  def get_text(key, opts \\ []) do
    template = get_template(key)
    source =
      case template do
        v when is_list(v) -> Enum.random(v)
        v -> v
      end

    EEx.eval_string(source, opts)
  end

  def get_template([key | rest]), do: get_template(get_template(key), rest)
  def get_template(key), do: Application.get_env(:katex, :text)[key]
  def get_template(template, []), do: template
  def get_template(template, [key | rest]) when is_map(template),
    do: get_template(template[key], rest)
  def get_template(template, [key | rest]) when is_list(template),
    do: get_template(Enum.at(template, key), rest)

  def loud?(text) do
    String.contains?(text, "!") or (String.upcase(text) == text)
  end

  def triggers(:all) do
    Application.get_env(:katex, :triggers)
  end
  def triggers(key) do
    triggers(:all)[key]
  end

  def find_triggers(text) do
    dtext = String.downcase(text)
    triggers_in_text =
      for {trigger_name, trigger_words} <- triggers(:all),
        String.contains?(dtext, trigger_words),
        do: trigger_name

    if loud?(text) do
      [:loud | triggers_in_text]
    else
      triggers_in_text
    end

  end

end
