defmodule MauricioTest.TextTest do
  use ExUnit.Case

  alias Mauricio.Text
  alias Mauricio.Text.Cat, as: CatName
  alias Mauricio.CatChat.{Member, Cat}

  test "triggers in text" do
    # КСтати - attract
    # сКУШай - eat
    # НЯшную - mew
    # КОТлетку - :cat
    # ! - loud
    text = """
    Кстати скушай няшную котлетку!
    """

    triggers = Text.find_triggers(text)
    assert [:loud, :attract, :cat, :eat, :mew] == triggers
  end

  test "Chain get" do
    assert Text.get_text([:satiety, 4]) == "Чавк-чавк-чавк!"
  end

  test "complex template" do
    cat = Cat.new("Cat")
    who = Member.new("Лол", "Кек", 1)

    assert Text.get_text([:satiety, 10, 0], who: who, cat: cat) == """
           <i>Cat долго принюхивается к еде. Он понимает, что не хочет есть, но Лол Кек говорит, что надо.</i>
           """

    assert Text.get_text([:satiety, 10, 0], who: :feeder, cat: cat) == """
           <i>Cat долго принюхивается к еде. Он понимает, что не хочет есть, но голос свыше говорит, что надо.</i>
           """
  end

  describe "fetch cat name" do
    test "returns capitalized name" do
      cat_name = CatName.capitalized_name_in(:every_nominative)
      assert cat_name == String.capitalize(cat_name)
    end

    test "returns random name from config" do
      names = Application.get_env(:mauricio, :name_variants) |> get_in([:every_nominative])
      assert CatName.name_in(:every_nominative) in names
    end

    test "returns real cat name according to probability in config" do
      expected = 0.6
      trials = for _ <- 1..10000, do: CatName.capitalized_name_in(:every_nominative, "Cat", expected)
      actual = Enum.count(trials, fn name -> name == "Cat" end) / 10000
      assert_in_delta actual, expected, 0.01
    end

    test "returns every possible name" do
      expected = Application.get_env(:mauricio, :name_variants) |> get_in([:every_nominative]) |> Enum.sort()
      actual = 1..1000 |> Enum.map(fn _ -> CatName.name_in(:every_nominative) end) |> Enum.uniq() |> Enum.sort()
      assert expected == actual
    end
  end
end
