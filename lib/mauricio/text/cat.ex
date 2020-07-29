defmodule Mauricio.Text.Cat do
  def name_in(inflection, real_name \\ nil, env)
  def name_in(_, _, :test), do: "cat"

  def name_in(inflection, real_name, _) when is_nil(real_name) do
    random_name_from_config(inflection, false)
  end

  def name_in(inflection, real_name, env) do
    name_in(inflection, env)
    |> weighted_choice(real_name, :rand.uniform(), Application.get_env(:mauricio, :real_name_probability))
  end

  def capitalized_name_in(inflection, real_name \\ nil, env)
  def capitalized_name_in(_, _, :test), do: "Cat"

  def capitalized_name_in(inflection, real_name, _) when is_nil(real_name) do
    random_name_from_config(inflection, true)
  end

  def capitalized_name_in(inflection, real_name, env) do
    capitalized_name_in(inflection, env)
    |> weighted_choice(real_name, :rand.uniform(), Application.get_env(:mauricio, :real_name_probability))
  end

  defp random_name_from_config(inflection, capitalize) do
    names_from_config(inflection, capitalize) |> Enum.random()
  end

  defp names_from_config(inflection, true) do
    Application.get_env(:mauricio, :text) |> get_in([:name_variants, inflection]) |> Enum.map(&String.capitalize/1)
  end

  defp names_from_config(inflection, false) do
    Application.get_env(:mauricio, :text) |> get_in([:name_variants, inflection])
  end

  defp weighted_choice(_, real_name, rand, prob) when rand < prob, do: real_name
  defp weighted_choice(other_name, _, _, _), do: other_name
end
