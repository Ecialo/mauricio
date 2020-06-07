defmodule MauricioTest.Member do
  use ExUnit.Case
  use PropCheck

  alias Mauricio.Storage.{Serializable, Decoder}
  alias Mauricio.CatChat.Member
  alias Mauricio.Text

  alias MauricioTest.TestData.Member, as: TestMember

  doctest Mauricio.CatChat.Member

  property "serialization preserve equality after encode-decode" do
    forall member <- TestMember.some_member(), [:verbose] do
      member ==
        member
        |> Serializable.encode()
        |> Decoder.decode()
    end
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
