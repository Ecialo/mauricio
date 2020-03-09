defmodule MauricioTest.Cat.State.Away do
  use ExUnit.Case

  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.State.{Awake, Away}
  alias Mauricio.Text

  alias MauricioTest.Helpers

  test "pet" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Away.new, 1, 1, 0)

    expected = Text.get_all_texts(:away_pet, who: member, cat: cat)
    {cat, _member, text} = Cat.pet(cat, member)

    assert Helpers.weak_text_eq(text, expected)
    assert cat.times_pet == 0
  end

  test "hug" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Away.new, 1, 1, 0)

    expected = Text.get_all_texts(:hug_away, who: member, cat: cat)
    {cat, _member, text} = Cat.hug(cat, member)

    assert Helpers.weak_text_eq(text, expected)
  end

  test "pine" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Away.new, 1, 1, 0)

    expected = Text.get_all_texts(:cat_is_back, who: member, cat: cat)
    {cat, _member, text} = Cat.pine(cat, member)

    assert Helpers.weak_text_eq(text, expected)
    assert cat.state == Awake.new()
  end
end
