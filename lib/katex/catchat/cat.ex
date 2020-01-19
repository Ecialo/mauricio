defmodule Katex.CatChat.Cat do

  alias __MODULE__, as: Cat
  alias Katex.CatChat.Member
  alias Katex.Text

  @type state() :: :awake | :sleep | :away | {:want_care, non_neg_integer}
  @type t() :: %Cat{
    name: String.t,
    state: state,
    weight: non_neg_integer,
    satiety: non_neg_integer,
    times_pet: non_neg_integer,
  }

  defstruct [name: nil, state: :awake, weight: 5, satiety: 3, times_pet: 0]

  def new(name) do
    %Cat{name: name}
  end
  def new(name, state, weight, satiety, times_pet) do
    %Cat{name: name, state: state, weight: weight, satiety: satiety, times_pet: times_pet}
  end

  def change_satiety(cat = %Cat{satiety: satiety, weight: weight}, :inc) do
    if satiety < 10 do
      {:ok, %{cat | satiety: satiety + 1}}
    else
      {:vomit, %{cat | satiety: 5, weight: round(weight * 0.9)}}
    end
  end

  def change_satiety(cat = %Cat{satiety: satiety}, :dec) do
    {:ok, %{cat | satiety: satiety - 1}}
  end

  def weight_dynamic(%Cat{satiety: satiety}) do
    case satiety do
      10 -> :inc
      0 -> :dec
      _ -> :ok
    end
  end

  # Pet
  @spec pet(Cat.t, Member.t) :: {Cat.t, Member.t, String.t}
  def pet(cat = %Cat{state: {:want_care, _times_not_pet}, times_pet: n}, who) do
    {
      %{cat | state: :awake, times_pet: n + 1},
      Member.change_karma(who, :inc),
      Text.get_text(:joyful_pet, who: who)
    }
  end

  def pet(cat = %Cat{state: :away}, who) do
    {
      cat,
      who,
      Text.get_text(:away_pet, who: who)
    }
  end

  def pet(cat = %Cat{state: :sleep}, who) do
    {
      cat,
      who,
      Text.get_text(:sleep_pet, who: who)
    }
  end

  def pet(cat = %Cat{state: :awake, times_pet: times_pet}, who) do
    unmood = :random.uniform(times_pet + 1)
    if unmood > 5 do
      {%{cat | times_pet: 0}, who, Text.get_text(:bad_pet, who: who, cat: cat)}
    else
      {%{cat | times_pet: times_pet + 1}, who, Text.get_text(:awake_pet, who: who)}
    end
  end

  # Hug
  def hug(cat = %Cat{state: :away}, who) do
    {cat, who, Text.get_text(:hug_away, who: who)}
  end

  def hug(cat = %Cat{state: state}, who) do
    state_message = case state do
      :awake -> "бегающего туда-сюда"
      :sleep -> "мирно спящего"
      {:want_care, 0} -> "непонятно чего хотящего"
      {:want_care, 1} -> "жаждущего ласки"
      {:want_care, _} -> "надоедливого"
    end

    karma_level = Member.karma_level(who)
    karma_action = case karma_level do
      :no_karma -> "недоуменно мяукает"
      :good_karma -> "радостно мурчит"
      :normal_karma -> "не придаёт вам значения"
      :bad_karma -> "шипит и вырывается"
    end
    state_prefix = case state do
      :sleep -> "просыпается, а затем "
      _ -> ""
    end
    cat_action = state_prefix<>karma_action

    dynamic = weight_dynamic(cat)
    cat_dynamic = state_dynamic_message(dynamic, karma_level, state)

    {
      %{cat | state: :awake},
      who,
      Text.get_text(
        :hug,
        who: who,
        cat: cat,
        state: state_message,
        cat_action: cat_action,
        cat_dynamic: cat_dynamic
      )
    }
  end

  def state_dynamic_message(weight_dynamic, karma_level, cat_state) do
    case {weight_dynamic, karma_level, cat_state} do
      {_, :bad_karma, {:want_care, _}} -> "расцарапал вам руку, но успокоился"
      {_, _, {:want_care, _}} -> "начал успокаиваться"
      {_, :bad_karma, _} -> "расцарапал вам руку"
      {:inc, _, _} -> "продолжает толстеть"
      {:dec, _, _} -> "продолжает худеть"
      {:ok, _, _} -> "вполне этим доволен"
    end
  end

end
