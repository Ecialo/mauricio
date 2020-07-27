defmodule Mauricio.Text.CatName do
  def fetch(inflection, capitalize) do
    names_from_config(inflection, capitalize) |> Enum.random()
  end

  def fetch(inflection, capitalize, real_name) do
    names_from_config(inflection, capitalize)
    |> weighted_choice(real_name, :rand.uniform(), Application.get_env(:mauricio, :real_name_probability))
  end

  defp names_from_config(inflection, true) do
    Application.get_env(:mauricio, :text) |> get_in([:name_variants, inflection]) |> Enum.map(&String.capitalize/1)
  end

  defp names_from_config(inflection, false) do
    Application.get_env(:mauricio, :text) |> get_in([:name_variants, inflection])
  end

  defp weighted_choice(_, real_name, rand, prob) when rand < prob, do: real_name
  defp weighted_choice(other_names, _, _, _), do: Enum.random(other_names)
end
