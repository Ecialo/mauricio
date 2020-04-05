# defmodule Mauricio.Storage.MongoStorage do
#   use GenServer
#   use Mauricio.Storage
#   alias __MODULE__, as: Storage

#   def init(_arg) do
#     Mongo.start_link(opts)
#   end

#   def handle_flush(_from, storage), do: :ok
# end
