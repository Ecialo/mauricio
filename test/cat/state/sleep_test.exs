defmodule MauricioTest.Cat.State.Sleep do
  use ExUnit.Case

  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.State.{Awake, Sleep}
  alias Mauricio.Text

  alias MauricioTest.Helpers

  setup do
    %{member: Member.new("A", "B", 1, 1, true), cat: Cat.new("C", Sleep.new(), 1, 1, 0)}
  end

  describe "pet" do
    test "shows message", %{member: member, cat: cat} do
      expected = Text.get_all_texts(:sleep_pet, who: member, cat: cat)
      {cat, _member, text} = Cat.pet(cat, member)

      assert Helpers.weak_text_eq(text, expected)
      assert cat.times_pet == 0
    end
  end

  describe "mew" do
    test "shows message", %{member: member, cat: cat} do
      expected = Text.get_all_texts(:sleep, who: member, cat: cat)
      {_cat, nil, text} = Cat.mew(cat, member)

      assert Helpers.weak_text_eq(text, expected)
    end
  end

  describe "loud_sound_reaction" do
    test "wakes cat up and decreases user's karma", %{member: member, cat: cat} do
      expected = Text.get_all_texts(:aggressive, who: member, cat: cat)
      {cat, new_member, text} = Cat.loud_sound_reaction(cat, member)

      assert Helpers.weak_text_eq(text, expected)
      assert cat.state == Awake.new()
      assert new_member.karma == member.karma - 1
    end
  end

  describe "tire" do
    test "replenishes cat's energy", %{member: member, cat: cat} do
      thin_cat = %{cat | energy: 0}
      cat = %{cat | weight: 10, energy: 0}

      test_cat_falling_asleep(thin_cat, member)
      test_cat_falling_asleep(cat, member)
    end

    test "wakes cat up when enough energy", %{member: member, cat: cat} do
      lazy_cat = %{cat | weight: 10, energy: 10}
      active_cat = %{cat | weight: 10, energy: 10, laziness: 32}

      test_cat_waking_up(lazy_cat, member, :wake_up_lazy)
      test_cat_waking_up(active_cat, member, :wake_up_active)
    end

    defp test_cat_falling_asleep(cat, member) do
      expected = Text.get_all_texts(:sleep, who: member, cat: cat)
      {cat, nil, text} = Cat.tire(cat, member)
      assert Helpers.weak_text_eq(text, expected)
      assert cat.state == Sleep.new()
      assert cat.energy == round(1 + cat.weight * 0.35)
    end

    defp test_cat_waking_up(cat, member, key) do
      expected = Text.get_all_texts(key, who: member, cat: cat)
      {cat, nil, text} = Cat.tire(cat, member)
      assert Helpers.weak_text_eq(text, expected)
      assert cat.state == Awake.new()
      assert cat.energy == cat.weight
    end
  end
end
