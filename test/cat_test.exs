defmodule KatexTest.CatTest do
  use ExUnit.Case

  alias Katex.CatChat.Cat
  alias Katex.CatChat.Member

  test "good awake pet" do
    member = Member.new("A", "B", 1, 1, True)
    cat = Cat.new("C", :awake, 1, 1, 0)

    expected_text = """
    <i>A B погладил котяру.</i>
    """

    {cat, _member, text} = Cat.pet(cat, member)

    assert text == expected_text
    assert cat.times_pet == 1
  end

  test "bad awake pet" do
    member = Member.new("A", "B", 1, 1, True)
    cat = Cat.new("C", :awake, 1, 1, 10000)

    expected_text = """
    <i>C недоволен и цапает A B за палец.</i>
    ШШШШ.
    """
    {cat, _member, text} = Cat.pet(cat, member)

    assert text == expected_text
    assert cat.times_pet == 0
  end

  test "joyful pet" do
    member = Member.new("A", "B", 1, 1, True)
    cat = Cat.new("C", {:want_care, 0}, 1, 1, 0)

    expected_text = """
    <i>A B погладил котика</i>
    Мурррррррр.
    """

    {cat, member, text} = Cat.pet(cat, member)

    assert cat.state == :awake
    assert cat.times_pet == 1
    assert member.karma == 2
    assert text == expected_text
  end

  test "away pet" do
    member = Member.new("A", "B", 1, 1, True)
    cat = Cat.new("C", :away, 1, 1, 0)
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
