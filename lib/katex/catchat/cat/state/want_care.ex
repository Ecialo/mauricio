defmodule Katex.CatChat.Cat.State.WantCare do
  alias __MODULE__, as: WantCare
  alias Katex.Text
  alias Katex.CatChat.{Cat, Member}
  alias Katex.CatChat.Cat.{State, CatState}
  alias Katex.CatChat.Cat.State.Awake

  @type t() :: %WantCare{times_not_pet: non_neg_integer}

  defstruct [times_not_pet: 0]

  def new do
    %WantCare{}
  end

  defimpl CatState do
    def pet(%WantCare{}, cat = %Cat{times_pet: n}, who) do
      {
        %{cat | state: Awake.new, times_pet: n + 1},
        Member.change_karma(who, :inc),
        Text.get_text(:joyful_pet, who: who)
      }
    end
    defdelegate hug(state, cat, who), to: State
    defdelegate mew(state, cat, who), to: Awake
    def lound_sound_reaction(%WantCare{}, _cat, _who), do: nil
    defdelegate tire(state, cat, who), to: Awake
    def pine(%WantCare{times_not_pet: 3}, cat, who),
      do: {%{cat | state: Awake.new}, who, Text.get_text(:sad)}
    def pine(%WantCare{times_not_pet: times_not_pet} = state, cat, who),
      do: {
        %{cat | state: %{state | times_not_pet: times_not_pet + 1}},
        who, Text.get_text(:mew)
      }
  end

end
