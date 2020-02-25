defmodule Katex.CatChat.Cat.State.Awake do
  alias __MODULE__, as: Awake
  alias Katex.Text
  alias Katex.CatChat.{Cat, Member}
  alias Katex.CatChat.Cat.{State, CatState}
  alias Katex.CatChat.Cat.State.{Sleep, Away, WantCare}

  defstruct []
  def new do
    %Awake{}
  end

  def pet(_state, cat = %Cat{times_pet: times_pet}, who) do
    unmood = :random.uniform(times_pet + 1)
    if unmood > 5 do
      {%{cat | times_pet: 0}, who, Text.get_text(:bad_pet, who: who, cat: cat)}
    else
      {%{cat | times_pet: times_pet + 1}, who, Text.get_text(:awake_pet, who: who)}
    end
  end

  def mew(_state, cat, who) do
    message = case Member.karma_level(who) do
      :bad_karma -> Text.get_text(:aggressive)
      _ -> Text.get_text(:mew)
    end
    {cat, who, message}
  end

  def eat(_state, cat, who) do
    case Cat.change_satiety(cat, :inc) do
      {:ok, new_cat} ->
        {new_cat, who, Text.get_text([:satiety, cat.satiety], who: who, cat: cat)}
      {:vomit, new_cat} ->
        {
          new_cat,
          Member.change_karma(who, :dec),
          Text.get_text([:satiety, :vomit], cat: cat, who: who)
        }
    end
  end

  def tire(_state, %Cat{energy: {0, _}} = cat, who) do
    {%{cat | state: Sleep.new}, who, Text.get_text(:fall_asleep, cat: cat, who: who)}
  end

  def tire(_state, cat, who) do
    {Cat.change_energy(cat, :dec), who, nil}
  end

  defimpl CatState do

    defdelegate pet(state, cat, who), to: Awake
    defdelegate hug(state, cat, who), to: State
    defdelegate mew(state, cat, who), to: Awake
    def loud_sound_reaction(%Awake{}, _cat, _who), do: nil
    defdelegate eat(state, cat, who), to: Awake
    defdelegate tire(state, cat, who), to: Awake
    def pine(%Awake{}, cat = %Cat{times_pet: times_pet}, who) when times_pet >= 4,
      do: {%{cat | state: Away.new}, who, Text.get_text(:going_out, cat: cat, who: who)}
    def pine(%Awake{}, cat, who),
      do: {%{cat | state: WantCare.new}, who, Text.get_text(:want_care, cat: cat, who: who)}
  end
end
