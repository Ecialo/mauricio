defmodule Mauricio.CatChat.Member do
  alias Nadia.Model.User, as: NadiaUser
  alias __MODULE__, as: Member

  @type t() :: %Member{
          fname: String.t(),
          sname: String.t(),
          id: integer(),
          karma: 0..10,
          participant?: boolean()
        }
  defstruct fname: nil, sname: nil, id: nil, karma: 3, participant?: true

  def new(fname, sname, id) do
    %Member{fname: fname, sname: sname, id: id}
  end

  def new(fname, sname, id, karma, participant?) do
    %Member{fname: fname, sname: sname, id: id, karma: karma, participant?: participant?}
  end

  def new(%NadiaUser{first_name: fname, last_name: sname, id: id}) do
    new(fname || "Anon", sname || "Anonych", id)
  end

  @spec change_karma(Member.t(), :inc | :dec) :: Member.t()
  def change_karma(member = %Member{karma: karma}, direction) do
    new_karma =
      case direction do
        :inc -> min(karma + 1, Application.get_env(:mauricio, :max_karma))
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

  def boxed(%Member{id: id} = member) do
    %{id => member}
  end
end
