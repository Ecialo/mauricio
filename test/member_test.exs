defmodule MauricioTest.Member do
  use ExUnit.Case

  alias Mauricio.CatChat.Member
  alias Mauricio.Text

  test "check person representation" do
    assert Member.full_name(Member.new("Ivan", "Ivanov", 1)) == "Ivan Ivanov"
    assert Member.full_name(Member.new("Ivan", nil, 1)) == "Ivan"
  end

  test "check string formatting" do
    assert Text.get_text(:awake_pet, who: Member.new("Ivan", "Ivanov", 1)) == """
           <i>Ivan Ivanov гладит котяру.</i>
           """

    assert Text.get_text(:awake_pet, who: Member.new("Ivan", nil, 1)) == """
           <i>Ivan гладит котяру.</i>
           """
  end
end
