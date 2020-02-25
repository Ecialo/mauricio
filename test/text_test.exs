defmodule KatexTest.CatTest do
  use ExUnit.Case

  alias Katex.Text
  alias Katex.CatChat.{Member, Cat}

  test "triggers in text" do
    # КСтати - attract
    # сКУШай - eat
    # НЯшную - mew
    # КОТлетку - eat
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
    assert Text.get_text([:satiety, 10, 1], who: who, cat: cat) == """
    <i>Пень не притрагивается к еде и смотрит на Лол Кек тяжелым взглядом полным бесконечного презрения</i>
    """
    assert Text.get_text([:satiety, 10, 1], who: :feeder, cat: cat) == """
    <i>Пень не притрагивается к еде и смотрит на кормушку тяжелым взглядом полным бесконечного презрения</i>
    """
  end

end
