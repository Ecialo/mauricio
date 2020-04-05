# defmodule Mauricio.Storage.LongTermStorage.Endpoint do
#   use GenServer

#   def start_link()
# end

defmodule Mauricio.Storage.LongTermStorage do
  use Supervisor
  alias Mauricio.Storage.LongTermStorage.Endpoint

  @cache Mauricio.Storage.LongTermStorage.Cache
  @long_term Mauricio.Storage.LongTermStorage.LongTerm
  def init(arg) do

  end

  def cache do
    @cache
  end

  def long_term do
    @long_term
  end
end
