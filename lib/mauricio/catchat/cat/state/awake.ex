defmodule Mauricio.CatChat.Cat.State.Awake do
  alias __MODULE__, as: Awake
  alias Mauricio.Text
  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.{State, CatState}
  alias Mauricio.CatChat.Cat.State.{Sleep, Away, WantCare}
  alias Mauricio.Storage.Serializable

  @derive [Serializable]
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
      :bad_karma -> Text.get_text(:aggressive, cat: cat, who: who)
      _ -> Text.get_text(:mew, cat: cat, who: who)
    end
    {cat, nil, message}
  end

  def eat(_state, cat, who) do
    case Cat.change_satiety(cat, :inc) do
      {:ok, new_cat} ->
        {new_cat, nil, Text.get_text([:satiety, cat.satiety], who: who, cat: cat)}
      {:vomit, new_cat} ->
        {
          new_cat,
          if is_struct(who) do Member.change_karma(who, :dec) end,
          Text.get_text([:satiety, :vomit], cat: cat, who: who)
        }
    end
  end

  def tire(_state, %Cat{energy: 0} = cat, who) do
    {%{cat | state: Sleep.new}, nil, Text.get_text(:fall_asleep, cat: cat, who: who)}
  end

  def tire(_state, cat, _who) do
    {Cat.change_energy(cat, :dec), nil, nil}
  end

  def metabolic(_state, cat, _who) do
    weight_dynamic = Cat.weight_dynamic(cat)
    message = case weight_dynamic do
      :inc -> cat.name <> " толстеет"
      :dec -> cat.name <> " худеет"
      :ok -> nil
    end
    {:ok, new_cat} = cat |> Cat.change_weight(weight_dynamic) |> Cat.change_satiety(:dec)
    {new_cat, nil, message}
  end

  def hungry(_state, cat, feeder) do
    {food, new_feeder} =
      case :queue.out(feeder) do
        {{_, food}, new_q} -> {food, new_q}
        {:empty, new_q} -> {:empty, new_q}
      end
    case food do
      :empty -> nil
      food ->
        [
          {new_feeder, nil, Text.get_text(:feeder_consume, cat: cat, food: food)},
          Cat.eat(cat, :no_one)
        ]
    end
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
    defdelegate metabolic(state, cat, who), to: Awake
    defdelegate react_to_triggers(state, cat, who, triggers), to: State
    defdelegate hungry(state, cat, feeder), to: Awake
  end
end
