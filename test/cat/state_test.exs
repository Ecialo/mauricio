defmodule MauricioTest.Cat.State do
  use ExUnit.Case
  use PropCheck

  alias Mauricio.Text
  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.State
  alias Mauricio.CatChat.Cat.State.Awake
  alias Mauricio.Storage.{Serializable, Decoder}

  alias MauricioTest.TestData.Cat, as: TestCat

  test "react to triggers" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Awake.new, 1, 1, 0)
    triggers = Text.find_triggers("Скушай!") |> IO.inspect()
    State.react_to_triggers(nil, cat, member, triggers)
  end

  test "hug" do
    member = Member.new("A", "B", 1, 10, true)
    cat = Cat.new("C", Awake.new, 1, 10, 0)
    expected = """
    <i>A B обнимает бегающего туда-сюда котика.
    C радостно мурчит. Навскидку котейка весит </i><b>1</b><i> кило и, кажется, продолжает толстеть.
    Этот кот слегка ленив.
    </i>
    """
    {_cat, _who, message} = Cat.hug(cat, member)
    assert message == expected
  end

  property "serialization preserve equality after encode-decode" do
    forall state <- TestCat.some_cat_state(), [:verbose] do
      state ==
        state
        |> Serializable.encode()
        |> Decoder.decode()
    end
  end
end
