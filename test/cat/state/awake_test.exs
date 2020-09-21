defmodule MauricioTest.Cat.State.Awake do
  use ExUnit.Case
  use ExUnit.Parameterized

  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.State
  alias Mauricio.CatChat.Cat.State.{Awake, Sleep, Away, WantCare}
  alias Mauricio.Text

  alias MauricioTest.Helpers

  setup do
    %{who: Member.new("A", "B", 1, 1, true), cat: Cat.new("C", Awake.new(), 1, 1, 0)}
  end

  describe "pet" do
    test "increases times_pet counter for not pet cat", %{who: who, cat: cat} do
      expected = Text.get_all_texts(:awake_pet, who: who, cat: cat)
      {cat, _member, text} = Cat.pet(cat, who)

      assert Helpers.weak_text_eq(text, expected)
      assert cat.times_pet == 1
    end

    test "resets times_pet counter and shows angry message for too many times pet cat", %{
      who: who,
      cat: cat
    } do
      cat = %{cat | times_pet: 10_000}
      expected_text = Text.get_all_texts(:bad_pet, who: who, cat: cat)
      {cat, _member, text} = Cat.pet(cat, who)

      assert Helpers.weak_text_eq(text, expected_text)
      assert cat.times_pet == 0
    end
  end

  describe "hug" do
    test "shows cat's current state message", %{who: who, cat: cat} do
      expected = """
      <i>A B обнимает бегающего туда-сюда cat.
      C не придаёт вам значения. Навскидку cat весит </i><b>1</b><i> кило и, кажется, продолжает худеть.
      Cat слегка ленив.
      </i>
      """

      {_cat, _who, message} = Cat.hug(cat, who)
      assert Helpers.weak_text_eq(expected, message)
    end
  end

  describe "mew" do
    test "responds to meowing depending on user's karma", %{who: member, cat: cat} do
      bad_member = %{member | karma: 0}

      expected_text = Text.get_all_texts(:mew, who: member, cat: cat)
      bad_expected_text = Text.get_all_texts(:aggressive, who: bad_member, cat: cat)
      {_cat, _member, text} = Cat.mew(cat, member)
      {_cat, _member, bad_text} = Cat.mew(cat, bad_member)

      assert Helpers.weak_text_eq(text, expected_text)
      assert Helpers.weak_text_eq(bad_text, bad_expected_text)
    end
  end

  describe "loud_sound_reaction" do
    test "does nothing", %{who: who, cat: cat} do
      assert nil == Cat.loud_sound_reaction(cat, who, [:loud])
    end
  end

  describe "eat" do
    test_with_params "increases satiety",
                     fn satiety ->
                       who = Member.new("A", "B", 1, 10, true)
                       cat = Cat.new("C", Awake.new(), 10, satiety, 0, 0)

                       expected_text =
                         Text.get_all_texts([:satiety, cat.satiety], cat: cat, who: who)

                       expected_anon =
                         Text.get_all_texts([:satiety, cat.satiety], cat: cat, who: :no_one)

                       {new_cat, _member, text} = Cat.eat(cat, who)
                       {new_cat_anon, _member, text_anon} = Cat.eat(cat, :no_one)

                       assert Helpers.weak_text_eq(text, expected_text)
                       assert Helpers.weak_text_eq(text_anon, expected_anon)

                       assert new_cat.satiety == satiety + 1
                       assert new_cat_anon.satiety == satiety + 1
                     end do
      Enum.map(0..10, &{&1})
    end

    test "makes cat vomit if satiety is too high", %{who: who, cat: cat} do
      cat = %{cat | satiety: 11, weight: 10}

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
  end

  describe "tire" do
    test "subtracts energy if there is some", %{who: who, cat: cat} do
      {new_cat, nil, nil} = Cat.tire(cat, who)
      assert new_cat.energy == cat.energy - 1
    end

    test "puts cat to sleep if there is no energy", %{who: who, cat: cat} do
      cat = %{cat | energy: 0}
      expected_text = Text.get_all_texts(:fall_asleep, cat: cat, who: who)
      {new_cat, nil, text} = Cat.tire(cat, who)

      assert Helpers.weak_text_eq(text, expected_text)
      assert new_cat.state == Sleep.new()
    end
  end

  describe "pine" do
    test "sends cat away after too many pets", %{who: who, cat: cat} do
      cat = %{cat | times_pet: 100}
      expected_text = Text.get_all_texts(:going_out, cat: cat, who: who)
      {cat, _who, text} = Cat.pine(cat, who)

      assert Helpers.weak_text_eq(text, expected_text)
      assert cat.state == Away.new()
    end

    test "resets times_pet counter", %{who: who, cat: cat} do
      cat = %{cat | times_pet: 100}
      {cat, _who, _text} = Cat.pine(cat, who)
      assert cat.state == Away.new()
      assert cat.times_pet == 0
      {cat, _who, _text} = Cat.pine(cat, who)
      assert cat.state == Awake.new()
      {cat, _who, _text} = Cat.pine(cat, who)
      assert cat.state == WantCare.new()
    end

    test "makes cat want to be pet", %{who: who, cat: cat} do
      expected_text = Text.get_all_texts(:want_care, cat: cat, who: who)
      {cat, _who, text} = Cat.pine(cat, who)

      assert Helpers.weak_text_eq(text, expected_text)
      assert cat.state == WantCare.new()
    end
  end

  describe "metabolic" do
    test "changes cat's weight", %{who: who, cat: cat} do
      cat = %{cat | weight: 5, satiety: 5}
      gain_weight_cat = %{cat | satiety: 10}
      loose_weight_cat = %{cat | satiety: 0}

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
  end

  describe "react_to_triggers" do
    test "react to triggers" do
      member = Member.new("A", "B", 1, 1, true)
      cat = Cat.new("C", Awake.new(), 1, 1, 0)
      triggers = Text.find_triggers("Скушай!")
      State.react_to_triggers(nil, cat, member, triggers)
    end
  end

  describe "hungry" do
    test "increases satiety when there is food", %{cat: cat} do
      feeder = :queue.from_list(["хрючево"])

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

    test "does nothing when there's no food", %{cat: cat} do
      feeder = :queue.new()
      assert nil == Cat.hungry(cat, feeder)
    end
  end
end
