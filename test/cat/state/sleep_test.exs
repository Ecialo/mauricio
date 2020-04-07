defmodule MauricioTest.Cat.State.Sleep do
  use ExUnit.Case

  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.State.{Awake, Sleep}
  alias Mauricio.Text

  alias MauricioTest.Helpers

  test "pet" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Sleep.new, 1, 1, 0)

    expected = Text.get_all_texts(:sleep_pet, who: member, cat: cat)
    {cat, _member, text} = Cat.pet(cat, member)

    assert Helpers.weak_text_eq(text, expected)
    assert cat.times_pet == 0
  end

  test "mew" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Sleep.new, 1, 1, 0)

    expected = Text.get_all_texts(:sleep, who: member, cat: cat)
    {_cat, nil, text} = Cat.mew(cat, member)

    assert Helpers.weak_text_eq(text, expected)
  end

  test "loud sound reaction" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Sleep.new, 1, 1, 0)

    expected = Text.get_all_texts(:aggressive, who: member, cat: cat)
    {cat, new_member, text} = Cat.loud_sound_reaction(cat, member)

    assert Helpers.weak_text_eq(text, expected)
    assert cat.state == Awake.new()
    assert new_member.karma == member.karma - 1
  end

  test "rest" do
    member = Member.new("A", "B", 1, 1, true)
    thin_cat = %{Cat.new("C", Sleep.new, 1, 0, 0) | energy: 0}
    cat = %{Cat.new("C", Sleep.new, 10, 0, 0) | energy: 0}

    expected = Text.get_all_texts(:sleep, who: member, cat: cat)
    {thin_cat, nil, thin_text} = Cat.tire(thin_cat, member)
    {cat, nil, text} = Cat.tire(cat, member)

    assert Helpers.weak_text_eq(thin_text, expected)
    assert Helpers.weak_text_eq(text, expected)
    assert cat.state == Sleep.new()
    assert cat.energy == round(1 + cat.weight * 0.35)
    assert thin_cat.state == Sleep.new()
    assert thin_cat.energy == round(1 + thin_cat.weight * 0.35)
  end

  test "rest to awake" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Sleep.new, 10, 0, 0)
    expected = Text.get_all_texts(:wake_up_lazy, who: member, cat: cat)
    {cat, nil, text} = Cat.tire(cat, member)
    assert Helpers.weak_text_eq(text, expected)
    assert cat.state == Awake.new
    assert cat.energy == cat.weight
  end

end
