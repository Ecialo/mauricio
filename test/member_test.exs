defmodule MauricioTest.Member do
  use ExUnit.Case
  use PropCheck

  alias Mauricio.Storage.{Serializable, Decoder}

  alias MauricioTest.TestData.Member, as: TestMember

  property "serialization preserve equality after encode-decode" do
    forall member <- TestMember.some_member(), [:verbose] do
      member ==
        member
        |> Serializable.encode()
        |> Decoder.decode()
    end
  end
end
