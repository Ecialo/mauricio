defmodule Mauricio.CatChat.Cat do
  alias __MODULE__, as: Cat
  alias Mauricio.CatChat.Cat.CatState
  alias Mauricio.CatChat.Cat.State.Awake
  alias Mauricio.Text
  alias Mauricio.Storage.Serializable

  @typedoc """
  {last_seen, backlog_newest, backlog_oldest}
  """
  @type news_track() :: {DateTime.t(), DateTime.t(), DateTime.t()}
  @type t() :: %Cat{
          name: String.t(),
          state: CatState.t(),
          weight: non_neg_integer(),
          satiety: 0..11,
          times_pet: non_neg_integer(),
          laziness: 1..1024,
          energy: non_neg_integer(),
          reqs: 0..10,
          # news: %{}
        }

  @derive [Serializable]
  defstruct name: nil,
            state: nil,
            weight: 5,
            satiety: 3,
            times_pet: 0,
            laziness: 64,
            energy: 5,
            reqs: 0

  def new(name) do
    %Cat{name: name, state: Awake.new()}
  end

  def new(name, state, weight, satiety, times_pet, laziness \\ 64) do
    %Cat{
      name: name,
      state: state,
      weight: weight,
      satiety: satiety,
      times_pet: times_pet,
      laziness: laziness,
      energy: weight
    }
  end

  def new(name, state, weight, satiety, times_pet, laziness, energy, reqs) do
    %Cat{
      name: name,
      state: state,
      weight: weight,
      satiety: satiety,
      times_pet: times_pet,
      laziness: laziness,
      energy: energy,
      reqs: reqs
    }
  end

  def become_lazy(%Cat{laziness: 1024} = cat, who),
    do: {cat, who, Text.get_text(:over_lazy)}

  def become_lazy(%Cat{laziness: l} = cat, who),
    do: {%{cat | laziness: l * 2}, who, Text.get_text(:become_lazy)}

  def become_annoying(%Cat{laziness: 1} = cat, who),
    do: {cat, who, Text.get_text(:over_annoying)}

  def become_annoying(%Cat{laziness: l} = cat, who),
    do: {%{cat | laziness: round(l / 2)}, who, Text.get_text(:become_annoying)}

  def change_satiety(%Cat{satiety: satiety, weight: weight} = cat, :inc) do
    if satiety <= 10 do
      {:ok, %{cat | satiety: satiety + 1}}
    else
      {:vomit, %{cat | satiety: 5, weight: round(weight * 0.9)}}
    end
  end

  def change_satiety(%Cat{satiety: satiety} = cat, :dec) do
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
    %{cat | energy: min(weight, round(energy + 1 + weight * 0.35))}
  end

  def change_energy(%Cat{energy: 0} = cat, :dec), do: cat

  def change_energy(%Cat{energy: energy} = cat, :dec),
    do: %{cat | energy: energy - 1}

  def change_weight(cat, :ok), do: cat

  def change_weight(%Cat{weight: weight} = cat, :inc),
    do: %{cat | weight: weight + 1}

  def change_weight(%Cat{weight: weight} = cat, :dec),
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
  def loud_sound_reaction(%Cat{state: state} = cat, who, triggers) do
    CatState.loud_sound_reaction(state, cat, who, triggers)
  end

  # Eat
  def eat(%Cat{state: state} = cat, who) do
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
  def react_to_triggers(cat = %Cat{state: state}, who, triggers) do
    CatState.react_to_triggers(state, cat, who, triggers)
  end
end
