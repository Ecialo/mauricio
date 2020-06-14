defmodule Mauricio.CatChat.Cat.State.Sleep do
  alias __MODULE__, as: Sleep
  alias Mauricio.Text
  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.{State, CatState}
  alias Mauricio.CatChat.Cat.State.Awake

  defstruct []

  @type t() :: %Sleep{}

  def new do
    %Sleep{}
  end

  defimpl CatState do
    @lazy_active_threshold 64
    def pet(%Sleep{}, cat, who),
      do: {cat, nil, Text.get_text(:sleep_pet, cat: cat, who: who)}

    defdelegate hug(state, cat, who), to: State

    def mew(%Sleep{}, cat, who),
      do: {cat, nil, Text.get_text(:sleep, cat: cat, who: who)}

    def loud_sound_reaction(%Sleep{}, cat, who),
      do:
        {%{cat | state: Awake.new()}, Member.change_karma(who, :dec),
         Text.get_text(:aggressive, cat: cat, who: who)}

    def tire(
          %Sleep{},
          %Cat{energy: energy, weight: weight, laziness: laziness} = cat,
          who
        )
        when energy >= weight,
        do:
          {%{cat | state: Awake.new()}, nil,
           wake_up_key(laziness) |> Text.get_text(who: who, cat: cat)}

    def tire(%Sleep{}, cat, who),
      do: {Cat.change_energy(cat, :inc), nil, Text.get_text(:sleep, who: who, cat: cat)}

    @spec pine(Mauricio.CatChat.Cat.State.Sleep.t(), any, any) :: nil
    def pine(%Sleep{}, _cat, _who), do: nil
    def eat(%Sleep{}, _cat, _who), do: nil
    def hungry(%Sleep{}, _cat, _who), do: nil
    defp wake_up_key(laziness) when laziness >= @lazy_active_threshold, do: :wake_up_lazy
    defp wake_up_key(_), do: :wake_up_active
    defdelegate metabolic(state, cat, who), to: Awake
    defdelegate react_to_triggers(state, cat, who, triggers), to: State
  end
end
