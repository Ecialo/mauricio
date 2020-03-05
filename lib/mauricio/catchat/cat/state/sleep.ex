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
      do: {cat, who, Text.get_text(:sleep_pet, who: who)}
    defdelegate hug(state, cat, who), to: State
    def mew(%Sleep{}, cat, who),
      do: {cat, who, Text.get_text(:sleep)}
    @spec loud_sound_reaction(
            Mauricio.CatChat.Cat.State.Sleep.t(),
            %{state: any},
            Mauricio.CatChat.Member.t()
          ) :: {%{state: Mauricio.CatChat.Cat.State.Awake.t()}, Mauricio.CatChat.Member.t(), any}
    def loud_sound_reaction(%Sleep{}, cat, who),
      do: {%{cat | state: Awake.new}, Member.change_karma(who, :dec), Text.get_text(:aggressive)}
    def tire(
      %Sleep{},
      %Cat{energy: energy, weight: weight} = cat,
      who
    ) when energy >= weight,
      do: {%{cat | state: Awake.new}, who, Text.get_text(:wake_up)}
    def tire(%Sleep{}, cat, who),
      do: {Cat.change_energy(cat, :inc), who, Text.get_text(:sleep)}
    def pine(%Sleep{}, _cat, _who), do: nil
    def eat(%Sleep{}, _cat, _who), do: nil
    def hungry(%Sleep{}, _cat, _who), do: nil
    defdelegate metabolic(state, cat, who), to: Awake
    defdelegate react_to_triggers(state, cat, who, triggers), to: State
  end

end
