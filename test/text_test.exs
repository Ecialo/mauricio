defmodule MauricioTest.TextTest do
  use ExUnit.Case

  alias Mauricio.Text
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
    cat = Cat.new("Пень")
    who = Member.new("Лол", "Кек", 1)

    assert Text.get_text([:satiety, 10, 0], who: who, cat: cat) == """
           <i>Пень долго принюхивается к еде. Он понимает, что не хочет есть, но Лол Кек говорит, что надо.</i>
           """

    assert Text.get_text([:satiety, 10, 0], who: :feeder, cat: cat) == """
           <i>Пень долго принюхивается к еде. Он понимает, что не хочет есть, но голос свыше говорит, что надо.</i>
           """
  end
end
