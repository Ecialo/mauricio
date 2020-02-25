defmodule Katex.Acceptor do
  @behaviour :elli_handler

  def handle(req, callback_args) do

  end

  def handle_event(event, args, config) do
    
  end

  def start_link(args) do
    :elli.start_link(
      port: args[:port],
      callback: __MODULE__,
      callback_args: args
    )
  end
end
