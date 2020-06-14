# defmodule Mauricio.Storage.LongTermStorage.Endpoint do
#   use Mauricio.Storage
#   alias Mauricio.Storage.LongTermStorage, as: LTS

#   @type storage :: nil

#   def handle_fetch(chat_id, from, _) do
#     case BaseStorage.fetch(chat_id, LTS.cache()) do
#       {:ok, _chat} = r ->
#         {:reply, r, nil}

#       :error ->
#         case BaseStorage.fetch(chat_id, LTS.long_term()) do
#           {:ok, chat} = r ->
#             GenServer.reply(from, r)
#             BaseStorage.put(chat, LTS.cache())
#             {:noreply, nil}
#         end
#     end
#   end

#   def handle_put(chat, _from, _) do
#     {:reply, BaseStorage.put(chat, LTS.cache()), nil}
#   end

#   def handle_flush(_from, _) do
#     with :ok <- BaseStorage.flush(LTS.long_term()),
#          :ok <- BaseStorage.flush(LTS.cache()) do
#       {:reply, :ok, nil}
#     else
#       :error -> {:reply, :error, nil}
#     end
#   end

#   def handle_pop(chat_id, _from, _) do
#     with :ok <- BaseStorage.pop(chat_id, LTS.long_term()),
#          :ok <- BaseStorage.pop(chat_id, LTS.cache()) do
#       {:reply, :ok, nil}
#     else
#       :error -> {:reply, :error, nil}
#     end
#   end

#   def handle_save(chat_id, _from, _) do
#     with {:ok, chat} <- BaseStorage.fetch(chat_id, LTS.cache()),
#          :ok <- BaseStorage.put(chat, LTS.long_term()) do
#       {:reply, :ok, nil}
#     else
#       :error -> {:reply, :error, nil}
#     end
#   end

# end

# defmodule Mauricio.Storage.LongTermStorage do
#   use Supervisor
#   alias Mauricio.Storage.LongTermStorage.Endpoint
#   alias Mauricio.Storage.{MongoStorage, MapStorage}

#   @cache Mauricio.Storage.LongTermStorage.Cache
#   @long_term Mauricio.Storage.LongTermStorage.LongTerm
#   def init(arg) do
#   end

#   def cache do
#     @cache
#   end

#   def long_term do
#     @long_term
#   end
# end
