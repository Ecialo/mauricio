defmodule Mauricio.CatChat.Cat do

  alias __MODULE__, as: Cat
  alias Mauricio.CatChat.Cat.CatState
  alias Mauricio.CatChat.Cat.State.Awake
  alias Mauricio.Text

  @type t() :: %Cat{
    name: String.t,
    state: CatState.t,
    weight: non_neg_integer,
    satiety: non_neg_integer,
    times_pet: non_neg_integer,
    laziness: pos_integer,
    energy: {non_neg_integer, non_neg_integer}
  }

  defstruct [name: nil, state: nil, weight: 5, satiety: 3, times_pet: 0, laziness: 64, energy: 5, reqs: 0]

  def new(name) do
    %Cat{name: name, state: Awake.new}
  end
  def new(name, state, weight, satiety, times_pet, laziness \\ 64) do
    %Cat{name: name, state: state, weight: weight, satiety: satiety, times_pet: times_pet, laziness: laziness, energy: weight}
  end

  def become_lazy(cat = %Cat{laziness: 1024}, who),
    do: {cat, who, Text.get_text(:over_lazy)}
  def become_lazy(cat = %Cat{laziness: l}, who),
    do: {%{cat | laziness: l * 2}, who, Text.get_text(:become_lazy)}

  def become_annoying(cat = %Cat{laziness: 1}, who),
    do: {cat, who, Text.get_text(:over_annoying)}
  def become_annoying(cat = %Cat{laziness: l}, who),
    do: {%{cat | laziness: round(l / 2)}, who, Text.get_text(:become_annoying)}

  def change_satiety(cat = %Cat{satiety: satiety, weight: weight}, :inc) do
    if satiety <= 10 do
      {:ok, %{cat | satiety: satiety + 1}}
    else
      {:vomit, %{cat | satiety: 5, weight: round(weight * 0.9)}}
    end
  end

  def change_satiety(cat = %Cat{satiety: satiety}, :dec) do
    {:ok, %{cat | satiety: max(satiety - 1, 0)}}
  end

  def weight_dynamic(%Cat{satiety: satiety}) do
    cond do
      satiety > 8 -> :inc
      satiety < 3 -> :dec
      true -> :ok
    end
  end

  def change_energy(%Cat{energy: energy, weight: weight} = cat, :inc) do
    %{cat | energy: min(weight, round(energy + weight * 0.35))}
  end

  def change_energy(%Cat{energy: 0} = cat, :dec), do: cat
  def change_energy(%Cat{energy: energy} = cat, :dec),
    do: %{cat | energy: energy - 1}

  def change_weight(cat, :ok), do: cat
  def change_weight(cat = %Cat{weight: weight}, :inc),
    do: %{cat | weight: weight + 1}
  def change_weight(cat = %Cat{weight: weight}, :dec),
    do: %{cat | weight: max(0, weight - 1)}

  # Pet
  def pet(%Cat{state: state} = cat, who) do
    CatState.pet(state, cat, who)
  end

  # Hug

  def hug(%Cat{state: state} = cat, who) do
    CatState.hug(state, cat, who)
  end

  # Mew

  def mew(%Cat{state: state} = cat, who) do
    CatState.mew(state, cat, who)
  end

  # Loud Sound
  def loud_sound_reaction(%Cat{state: state} = cat, who) do
    CatState.loud_sound_reaction(state, cat, who)
  end

  # Eat
  def eat(cat = %Cat{state: state}, who) do
    CatState.eat(state, cat, who)
  end

  # Tire
  def tire(%Cat{state: state} = cat, who) do
    CatState.tire(state, cat, who)
  end

  # Pine

  def pine(%Cat{state: state} = cat, who) do
    CatState.pine(state, cat, who)
  end

  # Metabolic

  def metabolic(%Cat{state: state} = cat, who) do
    CatState.metabolic(state, cat, who)
  end

  # Hungry
  def hungry(%Cat{state: state} = cat, feeder) do
    CatState.hungry(state, cat, feeder)
  end

  # React

  def react_to_triggers(cat = %Cat{state: state}, who, triggers),
    do: CatState.react_to_triggers(state, cat, who, triggers)

end
