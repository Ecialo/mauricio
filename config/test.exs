import Config

config :nadia,
  base_url: "http://localhost:32002/"

config :mauricio,
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
