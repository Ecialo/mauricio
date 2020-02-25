defmodule Katex.CatChat.Cat do

  alias __MODULE__, as: Cat
  alias Katex.CatChat.Member
  alias Katex.CatChat.Cat.CatState
  alias Katex.CatChat.Cat.State.Awake
  alias Katex.Text

  @type t() :: %Cat{
    name: String.t,
    state: CatState.t,
    weight: non_neg_integer,
    satiety: non_neg_integer,
    times_pet: non_neg_integer,
    laziness: pos_integer,
    energy: {non_neg_integer, non_neg_integer}
  }

  defstruct [name: nil, state: nil, weight: 5, satiety: 3, times_pet: 0, laziness: 64, energy: {5, 0}]

  def new(name) do
    %Cat{name: name, state: Awake.new}
  end
  def new(name, state, weight, satiety, times_pet, laziness) do
    %Cat{name: name, state: state, weight: weight, satiety: satiety, times_pet: times_pet, laziness: laziness, energy: {weight, 0}}
  end

  def become_lazy(cat = %Cat{laziness: 1024}, who),
    do: {cat, who, Text.get_text(:over_lazy)}
  def become_lazy(cat = %Cat{laziness: l}, who),
    do: {%{cat | laziness: l * 2}, who, Text.get_text(:become_lazy)}

  def become_annoying(cat = %Cat{laziness: 1}, who),
    do: {cat, who, Text.get_text(:over_annoying)}
  def become_annoying(cat = %Cat{laziness: l}, who),
    do: {%{cat | laziness: round(l / 2)}, who, Text.get_text(:become_annoying)}

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

  def change_energy(%Cat{energy: {energy, reqs}, weight: weight} = cat, :inc) do
    %{cat | energy: {
      min(weight, round(energy + weight * 0.35)),
      reqs
    }}
  end

  def change_energy(%Cat{energy: {0, _reqs}} = cat, :dec), do: cat
  def change_energy(%Cat{energy: {energy, reqs}} = cat, :dec),
    do: %{cat | energy: {energy - 1 , reqs}}

  # Pet
  def pet(%Cat{state: state} = cat, who) do
    CatState.pet(state, cat, who)
  end

  # Hug

  def hug(%Cat{state: state} = cat, who) do
    CatState.hug(state, cat, who)
  end

  # def hug(cat = %Cat{state: :away}, who) do
  #   {cat, who, Text.get_text(:hug_away, who: who)}
  # end

  # def hug(cat = %Cat{state: state}, who) do
  #   state_message = case state do
  #     :awake -> "бегающего туда-сюда"
  #     :sleep -> "мирно спящего"
  #     {:want_care, 0} -> "непонятно чего хотящего"
  #     {:want_care, 1} -> "жаждущего ласки"
  #     {:want_care, _} -> "надоедливого"
  #   end

  #   karma_level = Member.karma_level(who)
  #   karma_action = case karma_level do
  #     :no_karma -> "недоуменно мяукает"
  #     :good_karma -> "радостно мурчит"
  #     :normal_karma -> "не придаёт вам значения"
  #     :bad_karma -> "шипит и вырывается"
  #   end
  #   state_prefix = case state do
  #     :sleep -> "просыпается, а затем "
  #     _ -> ""
  #   end
  #   cat_action = state_prefix<>karma_action

  #   dynamic = weight_dynamic(cat)
  #   cat_dynamic = state_dynamic_message(dynamic, karma_level, state)

  #   {
  #     %{cat | state: :awake},
  #     who,
  #     Text.get_text(
  #       :hug,
  #       who: who,
  #       cat: cat,
  #       state: state_message,
  #       cat_action: cat_action,
  #       cat_dynamic: cat_dynamic
  #     )
  #   }
  # end

  # def state_dynamic_message(weight_dynamic, karma_level, cat_state) do
  #   case {weight_dynamic, karma_level, cat_state} do
  #     {_, :bad_karma, {:want_care, _}} -> "расцарапал вам руку, но успокоился"
  #     {_, _, {:want_care, _}} -> "начал успокаиваться"
  #     {_, :bad_karma, _} -> "расцарапал вам руку"
  #     {:inc, _, _} -> "продолжает толстеть"
  #     {:dec, _, _} -> "продолжает худеть"
  #     {:ok, _, _} -> "вполне этим доволен"
  #   end
  # end

  # Mew

  def mew(%Cat{state: state} = cat, who) do
    CatState.mew(state, cat, who)
  end

  # def mew(%Cat{state: :sleep} = cat, who) do
  #   {cat, who, Text.get_text(:sleep)}
  # end

  # def mew(%Cat{state: :away}, _who) do
    # nil
  # end

  # def mew(cat, who) do
  #   message = case Member.karma_level(who) do
  #     :bad_karma -> Text.get_text(:aggressive)
  #     _ -> Text.get_text(:mew)
  #   end
  #   {cat, who, message}
  # end

  # Loud Sound
  def loud_sound_reaction(%Cat{state: state} = cat, who) do
    CatState.loud_sound_reaction(state, cat, who)
  end

  # def loud_sound_reaction(%Cat{state: :sleep} = cat, who) do
  #   {%{cat | state: :awake}, Member.change_karma(who, :dec), Text.get_text(:aggressive)}
  # end

  # def loud_sound_reaction(cat, who) do
  #   {cat, who, nil}
  # end

  # Eat

  def eat(cat = %Cat{state: state}, who) do
    CatState.eat(state, cat, who)
  end

  # def eat(cat, %Member{karma: karma} = who) do
  #   case Cat.change_satiety(cat, :inc) do
  #     {:ok, new_cat} ->
  #       {new_cat, who, Text.get_text([:satiety, cat.satiety], who: who, cat: cat)}
  #     {:vomit, new_cat} ->
  #       {
  #         new_cat,
  #         %{who | karma: karma - 1},
  #         Text.get_text([:satiety, :vomit], cat: cat, who: who)
  #       }
  #   end
  # end

  # Tire
  def tire(%Cat{state: state} = cat, who) do
    CatState.tire(state, cat, who)
  end
  # def tire(%Cat{state: :awake, energy: {0, _}} = cat, who) do
  #   {%{cat | state: :sleep}, who, Text.get_text(:fall_asleep, cat: cat, who: who)}
  # end

  # def tire(%Cat{state: :awake, energy: {energy, reqs}} = cat, who) do
  #   {%{cat | energy: {energy - 1, reqs}}, who, nil}
  # end

  # def tire(%Cat{state: :sleep} = cat, who) do
  #   {Cat.rest(), who, Text.get_text(:sleep)}
  # end

  # Pine

  def pine(%Cat{state: state} = cat, who) do
    CatState.pine(state, cat, who)
  end

  # def pine(%Cat{times_pet: times_pet, state: :awake} = cat, who) when times_pet >= 4 do
  #   {%{cat | state: :away}, who, Text.get_text(:going_out, cat: cat, who: who)}
  # end

  # def pine(%Cat{state: :awake} = cat, who) do
  #   {%{cat | state: {:want_care, 0}}, who, Text.get_text(:want_care, cat: cat, who: who)}
  # end

  # def pine(%Cat{state: {:want_care, 3}} = cat, who) do
  #   {%{cat | state: :awake}, who, Text.get_text(:sad)}
  # end

  # def pine(%Cat{state: {:want_care, times_not_pet}} = cat, who) do
  #   {%{cat | state: {:want_care, times_not_pet + 1}}, who, Text.get_text(:mew)}
  # end

  # def pine(%Cat{state: :away} = cat, who) do
  #   {%{cat | state: :awake}, who, Text.get_text(:cat_is_back)}
  # end

  # React

  def react_to_triggers(cat = %Cat{state: state}, who, triggers),
    do: CatState.react_to_triggers(state, cat, who, triggers)

  # def react_to_triggers(cat, %Member{participant?: false} = who, triggers) do
  #   if :attract in triggers do
  #     {cat, %{who | participant?: true}, Text.get_text(:attracted)}
  #   end
  # end

  # def react_to_triggers(cat, who, triggers) do
  #   collect = fn tr, {cat, who, msgs} ->
  #     {cat, who, msg} = react_to_trigger(tr, cat, who)
  #     {cat, who, [msg | msgs]}
  #   end

  #   {cat, who, msgs} =
  #     Enum.reduce(triggers, {cat, who, []}, collect)

  #   {cat, who, Enum.reverse(msgs)}
  # end

  # defp react_to_trigger(:banish, cat, who) do
  #   {cat, %{who | participant?: false}, Text.get_text(:banished, cat: cat, who: who)}
  # end
  # defp react_to_trigger(:eat, cat, who) do
  #   eat(cat, who)
  # end
  # defp react_to_trigger(:mew, cat, who) do
  #   mew(cat, who)
  # end
  # defp react_to_trigger(:loud, cat, who) do
  #   loud_sound_reaction(cat, who)
  # end
  # defp react_to_trigger(tr, cat, who) when tr in [:cat, :dog] do
  #   {cat, who, tr}
  # end

end
