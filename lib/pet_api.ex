defmodule PetAPI do
  @cat_url "https://api.thecatapi.com/v1/"
  @dog_url "https://api.thedogapi.com/v1/"
  @search "images/search"

  @png ".png"
  @jpg ".jpg"
  @gif ".gif"

  def token(pet) do
    case pet do
      :cat -> Application.get_env(:mauricio, :cat_api_token)
      :dog -> Application.get_env(:mauricio, :dog_api_token)
    end
  end

  def api_url(pet) do
    case pet do
      :cat -> @cat_url
      :dog -> @dog_url
    end
  end

  def decode_response_body(response) do
    with {:ok, %HTTPoison.Response{body: body}} <- response,
         {:ok, result} <- Jason.decode(body, keys: :atoms),
         do: result
  end

  def request(pet, method, url, body \\ "", headers \\ %{}, options \\ []) do
    headers = Map.put(headers, "x-api-key", token(pet))
    HTTPoison.request(method, api_url(pet) <> url, body, headers, options)
  end

  def get_random_pet(pet) do
    match_url = fn url ->
      cond do
        String.ends_with?(url, @gif) -> {url, :animated}
        String.ends_with?(url, [@png, @jpg]) -> {url, :static}
        true -> {url, :unknown}
      end
    end

    request(pet, :get, @search)
    |> decode_response_body()
    |> hd
    |> Map.fetch!(:url)
    |> match_url.()
  end
end
