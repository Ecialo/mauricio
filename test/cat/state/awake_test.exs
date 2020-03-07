defmodule MauricioTest.Cat.State.Awake do
  use ExUnit.Case
  use ExUnit.Parameterized

  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.State.{Awake, Sleep, Away, WantCare}
  alias Mauricio.Text

  alias MauricioTest.Helpers

  test "good pet" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Awake.new, 1, 1, 0)

    expected = Text.get_all_texts(:awake_pet, who: member, cat: cat)
    {cat, _member, text} = Cat.pet(cat, member)

    assert Helpers.weak_text_eq(text, expected)
    assert cat.times_pet == 1
  end

  test "bad pet" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Awake.new, 1, 1, 10000)

    expected_text = Text.get_all_texts(:bad_pet, who: member, cat: cat)
    {cat, _member, text} = Cat.pet(cat, member)

    assert Helpers.weak_text_eq(text, expected_text)
    assert cat.times_pet == 0
  end

  test "mew" do
    member = Member.new("A", "B", 1, 10, true)
    bad_member = Member.new("BA", "BB", 1, 0, true)
    cat = Cat.new("C", Awake.new, 1, 1, 0, 0)

    expected_text = Text.get_all_texts(:mew, who: member, cat: cat)
    bad_expected_text = Text.get_all_texts(:aggressive, who: bad_member, cat: cat)
    {_cat, _member, text} = Cat.mew(cat, member)
    {_cat, _member, bad_text} = Cat.mew(cat, bad_member)

    assert Helpers.weak_text_eq(text, expected_text)
    assert Helpers.weak_text_eq(bad_text, bad_expected_text)
  end

  test "loud sound reaction" do
    who = Member.new("A", "B", 1, 10, true)
    cat = Cat.new("C", Awake.new, 1, 1, 0, 0)
    assert nil == Cat.loud_sound_reaction(cat, who)
  end


  test_with_params "eat normal",
    fn satiety ->
      who = Member.new("A", "B", 1, 10, true)
      cat = Cat.new("C", Awake.new, 10, satiety, 0, 0)

      expected_text = Text.get_all_texts([:satiety, cat.satiety], cat: cat, who: who)
      expected_anon = Text.get_all_texts([:satiety, cat.satiety], cat: cat, who: :no_one)

      {new_cat, _member, text} = Cat.eat(cat, who)
      {new_cat_anon, _member, text_anon} = Cat.eat(cat, :no_one)

      assert Helpers.weak_text_eq(text, expected_text)
      assert Helpers.weak_text_eq(text_anon, expected_anon)

      assert new_cat.satiety == satiety + 1
      assert new_cat_anon.satiety == satiety + 1
    end do
      Enum.map(0..10, &{&1,})
  end

  test "eat badly" do
    who = Member.new("A", "B", 1, 10, true)
    cat = Cat.new("C", Awake.new, 10, 11, 0, 0)

    expected_text = Text.get_all_texts([:satiety, :vomit], cat: cat, who: who)
    expected_anon = Text.get_all_texts([:satiety, :vomit], cat: cat, who: :no_one)

    {new_cat, new_member, text} = Cat.eat(cat, who)
    {new_cat_anon, new_member_anon, text_anon} = Cat.eat(cat, :no_one)

    assert Helpers.weak_text_eq(text, expected_text)
    assert Helpers.weak_text_eq(text_anon, expected_anon)

    assert new_cat.satiety == 5
    assert new_cat_anon.satiety == 5
    assert new_cat.weight == 9
    assert new_cat_anon.weight == 9
    assert new_member.karma == who.karma - 1
    assert new_member_anon == nil
  end

  test "tire normal" do
    who = Member.new("A", "B", 1, 10, true)
    cat = Cat.new("C", Awake.new, 10, 11, 0, 0)
    {new_cat, nil, nil} = Cat.tire(cat, who)
    assert new_cat.energy == cat.energy - 1
  end

  test "tire to sleep" do
    who = Member.new("A", "B", 1, 10, true)
    cat = Cat.new("C", Awake.new, 0, 11, 0, 0)

    expected_text = Text.get_all_texts(:fall_asleep, cat: cat, who: who)
    {new_cat, nil, text} = Cat.tire(cat, who)

    assert Helpers.weak_text_eq(text, expected_text)
    assert new_cat.state == Sleep.new()
  end

  test "pine away" do
    who = Member.new("A", "B", 1, 10, true)
    cat = Cat.new("C", Awake.new, 0, 11, 100, 0)

    expected_text = Text.get_all_texts(:going_out, cat: cat, who: who)
    {new_cat, _who, text} = Cat.pine(cat, who)

    assert Helpers.weak_text_eq(text, expected_text)
    assert new_cat.state == Away.new()
  end

  test "pine want care" do
    who = Member.new("A", "B", 1, 10, true)
    cat = Cat.new("C", Awake.new, 0, 11, 0, 0)

    expected_text = Text.get_all_texts(:want_care, cat: cat, who: who)
    {new_cat, _who, text} = Cat.pine(cat, who)

    assert Helpers.weak_text_eq(text, expected_text)
    assert new_cat.state == WantCare.new()
  end

  test "metabolic" do
    who = Member.new("A", "B", 1, 10, true)
    cat = Cat.new("C", Awake.new, 5, 5, 0, 0)
    gain_weight_cat = Cat.new("C", Awake.new, 5, 10, 0, 0)
    loose_weight_cat = Cat.new("C", Awake.new, 5, 0, 0, 0)

    gain_weight_text = "C толстеет"
    loose_weight_text = "C худеет"

    {new_cat, _who, nil} = Cat.metabolic(cat, who)
    assert new_cat.satiety == cat.satiety - 1

    {new_cat, _who, text} = Cat.metabolic(gain_weight_cat, who)
    assert text == gain_weight_text
    assert new_cat.satiety == gain_weight_cat.satiety - 1
    assert new_cat.weight == gain_weight_cat.weight + 1

    {new_cat, _who, text} = Cat.metabolic(loose_weight_cat, who)
    assert text == loose_weight_text
    assert new_cat.satiety == 0
    assert new_cat.weight == loose_weight_cat.weight - 1
  end

  test "hungry and food in feeder" do
    feeder = :queue.from_list(["хрючево"])
    cat = Cat.new("C", Awake.new, 5, 5, 0, 0)

    [
      {new_feeder, nil, food_from_feeder_message},
      {new_cat, nil, eat_message}
    ] = Cat.hungry(cat, feeder)

    {{:value, food}, n_f} = :queue.out(feeder)

    assert new_feeder == n_f
    assert new_cat.satiety == cat.satiety + 1
    assert Helpers.weak_text_eq(
      food_from_feeder_message,
      Text.get_all_texts(:feeder_consume, cat: cat, food: food)
    )
    assert Helpers.weak_text_eq(
      eat_message,
      Text.get_all_texts([:satiety, cat.satiety], cat: cat, who: :no_one)
    )

  end

end
