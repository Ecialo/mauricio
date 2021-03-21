import Config
alias Mauricio.News.Adapter

config :nadia,
  base_url: "http://localhost:32002/"

config :mauricio,
  news: %{
    # adapter module, url, opts, q size, fetch period
    panorama: {Adapter.Panorama, "", [], 8, 60 * 60 * 4}
  },
  storage: [
    type: :mongo,
    url:
      "mongodb://" <>
        System.get_env("MONGODB_HOST", "localhost") <>
        ":" <> System.get_env("MONGODB_PORT", "27017") <> "/db-name"
  ],
  real_name_probability: 0,
  name_variants: %{
    nominative: ["cat"],
    accusative: ["cat"],
    genitive: ["cat"],
    dative: ["cat"],
    every_nominative: [
      "кот",
      "котик",
      "котяра",
      "котофей",
      "котейка",
      "котэ",
      "кошак",
      "мурчало",
      "его пушистое величество",
      "мохнатый батон",
      "кисулькен",
      "котангенс",
      "котострофа",
      "меховой цветок"
    ]
  }

# config :mauricio, Mauricio.News,
