defmodule Mauricio.CatChat.Cat.State.Sleep do
  alias __MODULE__, as: Sleep
  alias Mauricio.Text
  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.{State, CatState}
  alias Mauricio.CatChat.Cat.State.Awake

  defstruct []

  def new do
    %Sleep{}
  end

  defimpl CatState do
    def pet(%Sleep{}, cat, who),
      do: {cat, nil, Text.get_text(:sleep_pet, cat: cat, who: who)}
    defdelegate hug(state, cat, who), to: State
    def mew(%Sleep{}, cat, who),
      do: {cat, nil, Text.get_text(:sleep, cat: cat, who: who)}
    def loud_sound_reaction(%Sleep{}, cat, who),
      do: {%{cat | state: Awake.new}, Member.change_karma(who, :dec), Text.get_text(:aggressive)}
    def tire(
      %Sleep{},
      %Cat{energy: energy, weight: weight} = cat,
      who
    ) when energy >= weight,
      do: {%{cat | state: Awake.new}, nil, Text.get_text(:wake_up, who: who, cat: cat)}
    def tire(%Sleep{}, cat, who),
      do: {Cat.change_energy(cat, :inc), nil, Text.get_text(:sleep, who: who, cat: cat)}
    def pine(%Sleep{}, _cat, _who), do: nil
    def eat(%Sleep{}, _cat, _who), do: nil
    def hungry(%Sleep{}, _cat, _who), do: nil
    defdelegate metabolic(state, cat, who), to: Awake
    defdelegate react_to_triggers(state, cat, who, triggers), to: State
  end

end
