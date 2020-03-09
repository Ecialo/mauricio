defmodule MauricioTest.Cat.State.WantCare do
  use ExUnit.Case

  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.State.{Awake, WantCare}
  alias Mauricio.Text

  alias MauricioTest.Helpers

  test "pet" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", WantCare.new, 1, 1, 0)

    expected = Text.get_all_texts(:joyful_pet, who: member, cat: cat)
    {new_cat, new_member, text} = Cat.pet(cat, member)

    assert Helpers.weak_text_eq(text, expected)
    assert new_cat.times_pet == cat.times_pet + 1
    assert new_member.karma == member.karma + 1
    assert new_cat.state == Awake.new()
  end

  test "pine" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", WantCare.new, 1, 1, 0)

    expected = Text.get_all_texts(:mew, who: member, cat: cat)
    {cat, nil, text} = Cat.pine(cat, member)
    assert Helpers.weak_text_eq(text, expected)
    assert cat.state == WantCare.new(1)
  end

  test "sad pine" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", WantCare.new(3), 1, 1, 0)

    expected = Text.get_all_texts(:sad, who: member, cat: cat)
    {cat, new_member, text} = Cat.pine(cat, member)
    assert Helpers.weak_text_eq(text, expected)
    assert cat.state == Awake.new()
    assert new_member.karma == member.karma - 1
  end
end
