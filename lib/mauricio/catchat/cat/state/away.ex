defmodule Mauricio.CatChat.Cat.State.Away do
  alias __MODULE__, as: Away
  alias Mauricio.Text
  alias Mauricio.CatChat.Cat.{State, CatState}
  alias Mauricio.CatChat.Cat.State.Awake

  defstruct []

  def new do
    %Away{}
  end

  defimpl CatState do
    def pet(%Away{}, cat, who),
      do: {cat, nil, Text.get_text(:away_pet, who: who)}

    def hug(%Away{}, cat, who),
      do: {cat, nil, Text.get_text(:hug_away, who: who)}

    def mew(%Away{}, _cat, _who), do: nil
    def loud_sound_reaction(%Away{}, _cat, _who), do: nil
    def tire(%Away{}, _cat, _who), do: nil

    def pine(%Away{}, cat, who),
      do: {%{cat | state: Awake.new()}, who, Text.get_text(:cat_is_back, cat: cat, who: who)}

    defdelegate react_to_triggers(state, cat, who, triggers), to: State
    def eat(%Away{}, _cat, _who), do: nil
    def hungry(%Away{}, _cat, _feeder), do: nil
    def metabolic(%Away{}, _cat, _who), do: nil
  end
end
