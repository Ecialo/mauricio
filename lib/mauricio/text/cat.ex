defmodule Mauricio.Text.Cat do
  def name_in(inflection, real_name \\ nil)

  def name_in(inflection, nil) do
    random_name_from_config(inflection, false)
  end

  def name_in(inflection, real_name) do
    name_in(inflection)
    |> weighted_choice(
      real_name,
      :rand.uniform(),
      Application.get_env(:mauricio, :real_name_probability)
    )
  end

  def capitalized_name_in(
        inflection,
        real_name \\ nil,
        probability \\ Application.get_env(:mauricio, :real_name_probability)
      )

  def capitalized_name_in(inflection, nil, _) do
    random_name_from_config(inflection, true)
  end

  def capitalized_name_in(inflection, real_name, probability) do
    capitalized_name_in(inflection)
    |> weighted_choice(real_name, :rand.uniform(), probability)
  end

  defp random_name_from_config(inflection, capitalize) do
    names_from_config(inflection, capitalize) |> Enum.random()
  end

  defp names_from_config(inflection, true) do
    Application.get_env(:mauricio, :name_variants)
    |> get_in([inflection])
    |> Enum.map(&String.capitalize/1)
  end

  defp names_from_config(inflection, false) do
    Application.get_env(:mauricio, :name_variants) |> get_in([inflection])
  end

  defp weighted_choice(_, real_name, rand, prob) when rand < prob, do: real_name
  defp weighted_choice(other_name, _, _, _), do: other_name
end
