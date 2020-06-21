defprotocol Mauricio.Storage.Serializable do
  @moduledoc """
  How to simplify data to formats allowed by mongodb. Shipped with this:

      iex> Mauricio.Storage.Serializable.encode(1)
      1

      iex> Mauricio.Storage.Serializable.encode(1.0)
      1.0

      iex> Mauricio.Storage.Serializable.encode("123")
      "123"

      iex> Mauricio.Storage.Serializable.encode(true)
      true

      iex> Mauricio.Storage.Serializable.encode(:lol)
      "__a__lol"

      iex> Mauricio.Storage.Serializable.encode({1, 2, 3})
      [["__t__", 0], 1, 2, 3]

      iex> Mauricio.Storage.Serializable.encode([1, 2, 3])
      [1, 2, 3]

      iex> Mauricio.Storage.Serializable.encode(%{a: 1, b: 2})
      [{"__t__", 1}, {"__a__a", 1}, {"__a__b", 2}]
  """
  def encode(data)
end

defimpl Mauricio.Storage.Serializable, for: [Integer, Float, BitString] do
  def encode(v), do: v
end

defimpl Mauricio.Storage.Serializable, for: Atom do
  alias Mauricio.Storage.Decoder
  def encode(bool) when is_boolean(bool), do: bool
  def encode(atom), do: Decoder.atom_field() <> Atom.to_string(atom)
end

defimpl Mauricio.Storage.Serializable, for: Tuple do
  alias Mauricio.Storage.Decoder

  def encode(tuple) do
    tuple
    |> Tuple.to_list()
    |> @protocol.encode()
    |> List.insert_at(0, Decoder.tuple_field())
  end
end

defimpl Mauricio.Storage.Serializable, for: List do
  def encode(list) do
    Enum.map(list, &@protocol.encode/1)
  end
end

defimpl Mauricio.Storage.Serializable, for: Map do
  alias Mauricio.Storage.Decoder

  def encode(map) do
    map
    |> Enum.map(fn {k, v} -> {encode_key(k), @protocol.encode(v)} end)
    |> List.insert_at(0, Decoder.map_field())
  end

  def encode_key(k) when is_integer(k) do
    Decoder.int_field() <> Integer.to_string(k)
  end

  def encode_key(k), do: @protocol.encode(k)
end

defimpl Mauricio.Storage.Serializable, for: Any do
  alias Mauricio.Storage.Decoder

  def encode(struct_) do
    struct_name = Atom.to_string(struct_.__struct__)

    struct_
    |> Map.from_struct()
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), @protocol.encode(v)} end)
    |> List.insert_at(0, Decoder.struct_field(struct_name))
  end
end
