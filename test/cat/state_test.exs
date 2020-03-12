defmodule MauricioTest.Cat.State do
  use ExUnit.Case

  alias Mauricio.Text
  alias Mauricio.CatChat.{Cat, Member}
  alias Mauricio.CatChat.Cat.State
  alias Mauricio.CatChat.Cat.State.Awake

  test "react to triggers" do
    member = Member.new("A", "B", 1, 1, true)
    cat = Cat.new("C", Awake.new, 1, 1, 0)
    triggers = Text.find_triggers("Скушай!") |> IO.inspect()
    r = State.react_to_triggers(nil, cat, member, triggers)
  end
end
