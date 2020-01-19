defmodule Katex do
  use Application

  def start(_type, _args) do
    update_provider =
      case Application.get_env(:katex, :update_provider) do
        :poller -> [{Katex.Poller, []}]
        nil -> []
      end

    children = [
      {Katex.CatChat, []}
      | update_provider
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
