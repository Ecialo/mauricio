defmodule MauricioTest.TestData.Cat do
  use PropCheck
  alias Mauricio.CatChat.Cat
  alias Mauricio.CatChat.Cat.State.{Awake, Away, Sleep, WantCare}

  def some_cat do
    powers_of_two =
      let x <- integer(0, 10) do
        :math.pow(2, x) |> round()
      end

    let [
      name <- utf8(100),
      state <- some_cat_state(),
      weight <- integer(1, 10000),
      satiety <- integer(0, 11),
      times_pet <- integer(0, 50),
      laziness <- powers_of_two,
      energy <- integer(0, 10000),
      reqs <- integer(0, 10)
    ] do
      Cat.new(
        name,
        state,
        weight,
        satiety,
        times_pet,
        laziness,
        energy,
        reqs
      )
    end
  end

  def some_cat_state do
    oneof([
      some_awake_state(),
      some_away_state(),
      some_sleep_state(),
      some_want_care_state()
    ])
  end

  def some_awake_state do
    exactly(Awake.new())
  end

  def some_away_state do
    exactly(Away.new())
  end

  def some_sleep_state do
    exactly(Sleep.new())
  end

  def some_want_care_state do
    let times_not_pet <- integer(0, 3) do
      %WantCare{times_not_pet: times_not_pet}
    end
  end
end

defmodule MauricioTest.TestData.Member do
  use PropCheck
  alias Mauricio.CatChat.Member

  def that_member(id) do
    let [
      fname <- utf8(100),
      sname <- utf8(100),
      karma <- integer(0, 10),
      participant? <- boolean()
    ] do
      Member.new(fname, sname, id, karma, participant?)
    end
  end

  def some_member do
    let id <- integer() do
      that_member(id)
    end
  end

  def some_members do
    let size <- integer(1, 10) do
      ids_list =
        such_that(
          ids <- vector(size, integer()),
          when: Enum.count(ids) == ids |> Enum.uniq() |> Enum.count()
        )

      let il <- ids_list do
        Enum.map(il, &that_member/1)
      end
    end
  end

end

defmodule MauricioTest.TestData do
  use PropCheck

  alias MauricioTest.TestData.{Member, Cat}
  alias Mauricio.CatChat.Chat

  def some_feeder do
    exactly(:queue.new())
  end

  def some_chat do
    let [
      chat_id <- integer(),
      members <- Member.some_members(),
      cat <- Cat.some_cat(),
      feeder <- some_feeder()
    ] do
      members = Map.new(members, &{&1.id, &1})
      Chat.new(chat_id, members, cat, feeder)
    end
  end
end
