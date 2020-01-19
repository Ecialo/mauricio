defmodule Katex.CatChat.Member do
  alias __MODULE__, as: Member
  @type t() :: %Member{
    fname: String.t,
    sname: String.t,
    id: integer,
    karma: non_neg_integer,
    participant?: boolean
  }
  defstruct [fname: nil, sname: nil, id: nil, karma: 3, participant?: false]

  def new(fname, sname, id) do
    %Member{fname: fname, sname: sname, id: id}
  end
  @spec new(String.t, String.t, integer, integer, boolean) :: Member.t
  def new(fname, sname, id, karma, participant?) do
    %Member{fname: fname, sname: sname, id: id, karma: karma, participant?: participant?}
  end

  @spec change_karma(Member.t(), :inc | :dec) :: Member.t()
  def change_karma(member = %Member{karma: karma}, direction) do
    new_karma = case direction do
      :inc -> min(karma + 1, Application.get_env(:katex, :max_karma))
      :dec -> max(karma - 1, 0)
    end
    %{member | karma: new_karma}
  end

  def karma_level(%Member{karma: karma, participant?: p}) do
    cond do
      not p -> :no_karma
      karma >= 3 -> :good_karma
      karma == 0 -> :bad_karma
      karma < 3 -> :normal_karma
    end
  end
end
