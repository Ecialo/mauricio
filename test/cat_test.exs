defmodule MauricioTest.CatTest do
  use ExUnit.Case

  alias Mauricio.Text
  alias Mauricio.CatChat.Cat
  alias Mauricio.CatChat.Member
  alias Mauricio.CatChat.Cat.State.{Awake, Away, Sleep, WantCare}

  alias MauricioTest.Helpers

  test "good awake pet" do
    member = Member.new("A", "B", 1, 1, True)
    cat = Cat.new("C", Awake.new, 1, 1, 0)

    expected_text = """
    <i>A B погладил котяру.</i>
    """
    expected = Text.get_all_texts(:awake_pet, who: member, cat: cat)
    {cat, _member, text} = Cat.pet(cat, member)

    assert Helpers.weak_text_eq(text, expected)
    assert cat.times_pet == 1
  end

  test "bad awake pet" do
    member = Member.new("A", "B", 1, 1, True)
    cat = Cat.new("C", Awake.new, 1, 1, 10000)

    expected_text = Text.get_all_texts(:bad_pet, who: member, cat: cat)
    {cat, _member, text} = Cat.pet(cat, member)

    assert Helpers.weak_text_eq(text, expected_text)
    assert cat.times_pet == 0
  end

  test "joyful pet" do
    member = Member.new("A", "B", 1, 1, True)
    cat = Cat.new("C", WantCare.new(), 1, 1, 0)

    expected_text = """
    <i>A B погладил котика</i>
    Мурррррррр.
    """

    {cat, member, text} = Cat.pet(cat, member)

    assert cat.state == Awake.new
    assert cat.times_pet == 1
    assert member.karma == 2
    assert text == expected_text
  end

  test "away pet" do
    member = Member.new("A", "B", 1, 1, True)
    cat = Cat.new("C", Away.new, 1, 1, 0)
    {cat, _member, text} = Cat.pet(cat, member)

    expected_text = """
    <i>A B хочет погладить котяру, но обнаруживает, что того нет дома.</i>
    """
    assert text == expected_text
    assert cat.times_pet == 0
  end

  # test "hug dynamic" do

  # end

end
