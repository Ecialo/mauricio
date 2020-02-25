defmodule Katex.CatChat.Cat.State.Sleep do
  alias __MODULE__, as: Sleep
  alias Katex.Text
  alias Katex.CatChat.{Cat, Member}
  alias Katex.CatChat.Cat.{State, CatState}
  alias Katex.CatChat.Cat.State.Awake

  defstruct []

  def new do
    %Sleep{}
  end

  defimpl CatState do
    def pet(%Sleep{}, cat, who),
      do: {cat, who, Text.get_text(:sleep_pet, who: who)}
    defdelegate hug(state, cat, who), to: State
    def mew(%Sleep{}, cat, who),
      do: {cat, who, Text.get_text(:sleep)}
    def loud_sound_reaction(%Sleep{}, cat, who),
      do: {%{cat | state: Awake.new}, Member.change_karma(who, :dec), Text.get_text(:aggressive)}
    def tire(
      %Sleep{},
      %Cat{energy: {energy, _reqs}, weight: weight} = cat,
      who
    ) when energy >= weight,
      do: {%{cat | state: Awake.new}, who, Text.get_text(:wake_up)}

    def tire(%Sleep{}, cat, who),
      do: {Cat.change_energy(cat, :inc), who, Text.get_text(:sleep)}

    def pine(%Sleep{}, _cat, _who), do: nil
  end

end
