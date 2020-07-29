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

    assert Text.get_text([:satiety, 10, 1], who: who, cat: cat) == """
           <i>Cat не притрагивается к еде и смотрит на Лол Кек тяжелым взглядом, полным бесконечного презрения.</i>
           """

    assert Text.get_text([:satiety, 10, 1], who: :feeder, cat: cat) == """
           <i>Cat не притрагивается к еде и смотрит на кормушку тяжелым взглядом, полным бесконечного презрения.</i>
           """
  end

  describe "fetch cat name" do
    test "returns capitalized name" do
      cat_name = CatName.capitalized_name_in(:nominative, :not_test)
      assert cat_name == String.capitalize(cat_name)
    end

    test "returns random name from config" do
      names = Application.get_env(:mauricio, :text) |> get_in([:name_variants, :nominative])
      assert CatName.name_in(:nominative, :not_test) in names
    end

    test "returns real cat name according to probability in config" do
      trials = for _ <- 1..10000, do: CatName.capitalized_name_in(:nominative, "Cat", :not_test)
      actual = Enum.count(trials, fn name -> name == "Cat" end) / 10000
      assert_in_delta actual, Application.get_env(:mauricio, :real_name_probability), 0.01
    end

    test "returns every possible name" do
      expected = Application.get_env(:mauricio, :text) |> get_in([:name_variants, :nominative]) |> Enum.sort()
      actual = 1..1000 |> Enum.map(fn _ -> CatName.name_in(:nominative, :not_test) end) |> Enum.uniq() |> Enum.sort()
      assert expected == actual
    end
  end
end
