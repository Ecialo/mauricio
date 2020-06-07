defmodule Mauricio.CatChat.Cat.State.WantCare do
  alias __MODULE__, as: WantCare
  alias Mauricio.Text
  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.{State, CatState}
  alias Mauricio.CatChat.Cat.State.Awake

  @type t() :: %WantCare{times_not_pet: non_neg_integer}

  defstruct times_not_pet: 0

  def new do
    %WantCare{}
  end

  def new(times_not_pet) do
    %WantCare{times_not_pet: times_not_pet}
  end

  defimpl CatState do
    def pet(%WantCare{}, %Cat{times_pet: n} = cat, who) do
      {
        %{cat | state: Awake.new(), times_pet: n + 1},
        Member.change_karma(who, :inc),
        Text.get_text(:joyful_pet, who: who, cat: cat)
      }
    end

    defdelegate hug(state, cat, who), to: State
    defdelegate mew(state, cat, who), to: Awake
    defdelegate eat(state, cat, who), to: Awake
    defdelegate hungry(state, cat, feeder), to: Awake
    def loud_sound_reaction(%WantCare{}, _cat, _who), do: nil
    defdelegate metabolic(state, cat, who), to: Awake
    defdelegate tire(state, cat, who), to: Awake

    def pine(%WantCare{times_not_pet: 3}, cat, who),
      do:
        {%{cat | state: Awake.new()}, Member.change_karma(who, :dec),
         Text.get_text(:sad, who: who, cat: cat)}

    def pine(%WantCare{times_not_pet: times_not_pet} = state, cat, who),
      do: {
        %{cat | state: %{state | times_not_pet: times_not_pet + 1}},
        nil,
        Text.get_text(:mew, who: who, cat: cat)
      }

    defdelegate react_to_triggers(state, cat, who, triggers), to: State
  end
end
