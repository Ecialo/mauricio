defprotocol Mauricio.CatChat.Cat.CatState do
  def pet(state, cat, who)

  def hug(state, cat, who)

  def mew(state, cat, who)

  def loud_sound_reaction(state, cat, who)

  def eat(state, cat, who)

  def hungry(state, cat, feeder)

  def tire(state, cat, who)

  def pine(state, cat, who)

  def metabolic(state, cat, who)

  def dinner_call(state, cat, who)

  def react_to_triggers(state, cat, who, triggers)
end

defmodule Mauricio.CatChat.Cat.State do
  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.Text
  alias Mauricio.CatChat.Cat.State.{WantCare, Awake, Sleep}

  def state_dynamic_message(weight_dynamic, karma_level, cat_state) do
    case {weight_dynamic, karma_level, cat_state} do
      {_, :bad_karma, %WantCare{}} -> "расцарапал вам руку, но успокоился"
      {_, _, %WantCare{}} -> "начал успокаиваться"
      {_, :bad_karma, _} -> "расцарапал вам руку"
      {:inc, _, _} -> "продолжает толстеть"
      {:dec, _, _} -> "продолжает худеть"
      {:ok, _, _} -> "вполне этим доволен"
    end
  end

  def hug(state, cat, who) do
    karma_level = Member.karma_level(who)

    karma_action =
      case karma_level do
        :no_karma -> "недоуменно мяукает"
        :good_karma -> "радостно мурчит"
        :normal_karma -> "не придаёт вам значения"
        :bad_karma -> "шипит и вырывается"
      end

    {
      %{cat | state: Awake.new()},
      who,
      Text.get_text(
        :hug,
        who: who,
        cat: cat,
        state: common_state_message(state),
        cat_action: state_prefix(state) <> karma_action,
        cat_dynamic: cat_dynamic(cat, karma_level, state),
        laziness: cat_laziness(cat)
      )
    }
  end

  defp common_state_message(state) do
    case state do
      %Awake{} -> "бегающего туда-сюда"
      %Sleep{} -> "мирно спящего"
      %WantCare{times_not_pet: 0} -> "непонятно чего хотящего"
      %WantCare{times_not_pet: 1} -> "жаждущего ласки"
      %WantCare{} -> "изнывающего"
    end
  end

  defp state_prefix(state) do
    case state do
      %Sleep{} -> "просыпается, а затем "
      _ -> ""
    end
  end

  defp cat_dynamic(cat, karma_level, state) do
    cat
    |> Cat.weight_dynamic()
    |> state_dynamic_message(karma_level, state)
  end

  defp cat_laziness(cat), do: Text.get_text([:laziness, cat.laziness])

  def react_to_triggers(_state, cat, %Member{participant?: false} = who, triggers) do
    if :attract in triggers do
      {cat, %{who | participant?: true}, Text.get_text(:attracted)}
    end
  end

  def react_to_triggers(_state, cat, who, triggers) do
    collect = fn tr, {cat, who, msgs} ->
      case react_to_trigger(tr, cat, who, triggers) do
        nil -> {cat, who, msgs}
        {cat, nil, msg} -> {cat, who, [msg | msgs]}
        {cat, who, msg} -> {cat, who, [msg | msgs]}
      end
    end

    {cat, who, msgs} = Enum.reduce(triggers, {cat, who, []}, collect)

    {cat, who, Enum.reverse(msgs)}
  end

  defp react_to_trigger(:attract, _, _, _), do: nil

  defp react_to_trigger(:banish, cat, who, _) do
    {cat, %{who | participant?: false}, Text.get_text(:banished, cat: cat, who: who)}
  end

  defp react_to_trigger(:eat, cat, who, _) do
    Cat.eat(cat, who)
  end

  defp react_to_trigger(:mew, cat, who, _) do
    Cat.mew(cat, who)
  end

  defp react_to_trigger(:loud, cat, who, triggers) do
    cond do
      :eat in triggers -> Cat.dinner_call(cat, who)
      true -> Cat.loud_sound_reaction(cat, who)
    end
  end

  defp react_to_trigger(tr, cat, who, _) when tr in [:cat, :dog] do
    {cat, who, tr}
  end
end
