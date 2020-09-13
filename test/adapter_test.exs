defmodule MauricioTest.Adapter do
  use ExUnit.Case
  alias Mauricio.News.Adapter.Panorama

  test "panorama transfrom" do
    f = File.read!("test/test_data/panorama.html")
    {:ok, doc} = Floki.parse_document(f)
    headlines = Panorama.transform(doc)

    expected_headlines = [
      {"2020-08-23T10:00:16+00:00",
       "В белорусском Стратхольмске замечена неопознанная колонна военных",
       "https://panorama.pub/45407-v-belorusskom-stratholmske-zamechena-neopoznannaya-kolonna-voennyh.html"},
      {"2020-08-23T09:40:16+00:00",
       "Авиакомпания «Победа» обяжет пассажиров сдавать детей до 5 лет в багаж",
       "https://panorama.pub/45755-aviakompaniya-pobeda-obyazhet.html"},
      {"2020-08-22T18:31:00+00:00", "Новый родильный дом в Калуге получил имя маршала Жукова",
       "https://panorama.pub/45714-rodilnyj-dom-v-kaluge.html"},
      {"2020-08-22T14:45:13+00:00",
       "Елена Малышева потребовала билеты домой в обмен на американскую вакцину от COVID-19",
       "https://panorama.pub/45724-elena-malysheva-potrebovala.html"},
      {"2020-08-22T11:29:55+00:00",
       "Россиянам, живущим за чертой бедности, предложат льготную эвтаназию",
       "https://panorama.pub/45720-rossiyanam-evtanaziyu.html"},
      {"2020-08-22T09:01:03+00:00", "Польша в рамках декоммунизации заменила Россию на Кастовию",
       "https://panorama.pub/45712-polsha-v-ramkah.html"},
      {"2020-08-22T07:33:01+00:00",
       "Минздрав: вакцина от COVID-19 будет бесплатной при условии оплаты добровольного сбора",
       "https://panorama.pub/45749-minzdrav-vaktsina-ot-covid-19.html"},
      {"2020-08-22T05:50:41+00:00",
       "Мэр российского города на патриотическом митинге ко Дню флага прорекламировал онлайн-казино",
       "https://panorama.pub/45743-mer-rossijskogo-goroda.html"},
      {"2020-08-22T04:29:39+00:00",
       "Белорусская команда КВН объявила забастовку и отказалась выступать в Высшей лиге",
       "https://panorama.pub/45726-belorusskaya-komanda-kvn.html"},
      {"2020-08-22T04:17:56+00:00",
       "Великобритания запретила экспорт чая в Россию после отравления Навального",
       "https://panorama.pub/45630-velikobritaniya-zapretila-vvoz.html"},
      {"2020-08-21T18:01:16+00:00",
       "Материнский капитал разрешат использовать для пополнения счетов в букмекерских конторах",
       "https://panorama.pub/45706-matkapital-razreshat.html"},
      {"2020-08-21T16:10:43+00:00",
       "Российский одеколон Boris с ароматом перегара завоевал сердца миллиона европейских женщин",
       "https://panorama.pub/45661-rossijskij-odekolon-boris-s-aromatom-peregara-zavoeval-serdtsa-milliona-evropejskih-zhenshhin.html"}
    ]

    assert headlines == expected_headlines
  end
end
