import Config

config :mauricio,
  max_karma: 10,
  default_name: "Мяурицио",
  text: %{
    attracted: "Мурмурмур",
    banished: """
    <i><%= CatName.fetch(:nominative, true, cat.name) %> даёт дёру от <%= Member.full_name(who) %>.</i>
    """,
    start: """
    <i>У вас завелся котик. Сейчас он тихо сидит в уголке.
    Как его зовут?</i>
    """,
    name_cat: """
    <i><%= CatName.fetch(:dative, true) %> нравится имя <%= cat.name %>.</i>
    """,
    noname_cat: """
    <i>Котик решил, что будет зваться <%= cat.name %>.</i>
    """,
    already_cat: "<i>У вас уже есть котик!</i>",
    away_pet: """
    <i><%= Member.full_name(who) %> хочет погладить <%= CatName.fetch(:accusative, false) %>, но обнаруживает, что того нет дома.</i>
    """,
    awake_pet: """
    <i><%= Member.full_name(who) %> гладит <%= CatName.fetch(:accusative, false) %>.</i>
    """,
    bad_pet: [
      """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> недоволен и цапает <%= Member.full_name(who) %> за палец.</i>
      ШШШШ.
      """,
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> яростно дерется лапой.</i>",
      """
      <i>Когда <%= Member.full_name(who) %> пытается погладить <%= CatName.fetch(:accusative, false) %>, тот прогибает спину и не дает прикоснуться.</i>
      """,
      """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> изо всех сил отпинывается от рук <%= Member.full_name(who) %> задними лапами.</i>
      """
    ],
    joyful_pet: """
    <i><%= Member.full_name(who) %> гладит <%= CatName.fetch(:accusative, false) %>.</i>
    Мурррррррр.
    """,
    sad_pet: "Мямямяууууу...",
    sleep_pet: """
    <i><%= Member.full_name(who) %> гладит спящего <%= CatName.fetch(:accusative, false) %>.</i>
    """,
    hug_away: """
    <i><%= Member.full_name(who) %> хочет обнять <%= CatName.fetch(:accusative, false) %>, но того нет дома.</i>
    """,
    hug: """
    <i><%= Member.full_name(who) %> обнимает <%= state %> <%= CatName.fetch(:accusative, false) %>.
    <%= cat.name %> <%= cat_action %>. Навскидку <%= CatName.fetch(:nominative, false, cat.name) %> весит </i><b><%= cat.weight %></b><i> кило и, кажется, <%= cat_dynamic %>.
    <%= CatName.fetch(:nominative, true, cat.name) %> <%= laziness %>
    </i>
    """,
    become_lazy: """
    Вы чувствуете, как <%= CatName.fetch(:nominative, false) %> стал ещё ленивее.
    """,
    over_lazy: """
    Ленивей этому <%= CatName.fetch(:dative, false) %> уже не стать!
    """,
    become_annoying: """
    Вы чувствуете, как <%= CatName.fetch(:nominative, false) %> стал ещё надоедливей.
    """,
    over_annoying: """
    Надоедливей этому <%= CatName.fetch(:dative, false) %> уже не стать!
    """,
    mew: [
      "МЯУ!",
      "Мяу!",
      "Мяяяяу",
      "Мияу",
      "Мау!",
      "МААААУ!",
      "Меяу",
      "Мурр! Мафф!",
      "Ня",
      "Няяяяяя",
      "Няняияу",
      "Мямяу!",
      "Мррр!"
    ],
    aggressive: [
      "ШШШшШшШ!!!",
      "ШшШшШшШшшшшш!",
      "МмшшшШШШШ!",
      "Шшшшшшшшшшшшш....",
      """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> утробно рычит на <%= Member.full_name(who) %>.</i>
      """,
      "ХСССССССС!!!",
      "У-у-у-рррррр! ШШ!",
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> дерется и норовит укусить!</i>",
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> рычит и убегает под диван.</i>"
    ],
    sleep: [
      "Хрррр-Хрррр",
      "Хр-Хр-Хр",
      "ХРРРРРРРРРР!",
      "Хрррхррвап...",
      "ХррХррр",
    ],
    wake_up_lazy: "<i><%= CatName.fetch(:nominative, true, cat.name) %> проснулся, но только для того, чтобы пожрать.</i>",
    wake_up_active:
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> проснулся, потянулся и снова готов носиться по комнате.</i>",
    satiety: %{
      0 => [
        "ОМНОМНОМНОМНОМНОМНОМ!!!",
        "<i><%= CatName.fetch(:nominative, true, cat.name) %> заточил всю еду в мгновение ока.</i>",
        "<i><%= CatName.fetch(:nominative, true, cat.name) %> слопал еду и даже кормушку слегка погрыз!</i>",
      ],
      1 => [
        "<i>Громко мурча и чавкая, <%= CatName.fetch(:nominative, false) %> уплетает свою еду, а потом вылизывает кормушку.</i>",
        "НЯМ-НЯМ-НЯМ!"
      ],
      2 => [
        "<i><%= CatName.fetch(:nominative, true, cat.name) %> навернул от души!</i>",
        "Хрум-хрум-хрум"
      ],
      3 => [
        "<i><%= CatName.fetch(:nominative, true, cat.name) %> покушал и очень этим доволен.</i>",
        "<i><%= CatName.fetch(:nominative, true, cat.name) %> трескает с большим удовольствием.</i>"
      ],
      4 => "Чавк-чавк-чавк!",
      5 => "<i><i><%= CatName.fetch(:nominative, true, cat.name) %> хорошо перекусил.</i>",
      6 => "<i><%= CatName.fetch(:nominative, true, cat.name) %> поел.</i>",
      7 => "<i><%= CatName.fetch(:nominative, true, cat.name) %> все еще делает вид, что ему вкусно.</i>",
      8 => "<i><%= CatName.fetch(:nominative, true, cat.name) %> без особого энтузиазма съедает свой корм.</i>",
      9 => "<i>В <%= CatName.fetch(:accusative, false) %> едва лезет!</i>",
      10 => [
        "<i><%= CatName.fetch(:nominative, true, cat.name) %> долго принюхивается и зарывает кормушку.</i>",
        """
        <i><%= CatName.fetch(:nominative, true, cat.name) %> не притрагивается к еде и смотрит на <%= if not is_atom(who) do Member.full_name(who) else "кормушку" end %> тяжелым взглядом, полным бесконечного презрения.</i>
        """,
      ],
      vomit: """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> съел слишком много, и его стошнило. <%= if not is_atom(who) do Member.full_name(who) <> ", это твоя вина!" else "В этом явно виноват только он сам." end %></i>
      """
    },
    stop: "<i><%= CatName.fetch(:nominative, true) %> выпрыгнул с балкона и убежал.</i>",
    food_to_feeder: """
    <i><%= Member.full_name(who) %> добавляет</i> <b><%= new_food %></b> <i>в кормушку.</i>
    """,
    feeder_overflow: """
    <i>Так как кормушка была переполнена, из неё вывалился недоеденный корм, а именно </i> <b><%= old_food %>.</b>
    """,
    feeder_content: """
    <i>В кормушке сейчас <%= if length(all_food) == 1 do "лежит" else "ровными слоями лежат" end %></i> <b><%= Enum.join(all_food, ", ") %>.</b>
    """,
    added_nothing: """
    <i><%= Member.full_name(who) %> только делает вид, что что-то добавляет в кормушку. В глазах <%= CatName.fetch(:genitive, false) %> недоумение и разочарование.</i>
    """,
    added_self: """
    <i><%= Member.full_name(who) %> пытается добавить в кормушку самого <%= CatName.fetch(:accusative, false) %>! Какой ужас!</i>
    """,
    fall_asleep: [
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> сладко уснул на диване, выставив теплое пузико напоказ.</i>",
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> заснул и теперь дёргает лапками и ушами. Кажется, ему что-то снится.</i>",
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> свернулся клубочком и закрыл нос пушистым хвостом.</i>",
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> распластался в пятне солнечного света и сладко посапывает во сне.</i>",
      "<i>От громкого храпа котика дрожат оконные рамы!</i>",
      """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> устроился прямо на лучших штанах <%= Member.full_name(who) %> и равномерно покрыл их своей шерстью.</i>
      """,
      """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> спит на коленях <%= Member.full_name(who) %> и пускает слюни.</i>
      """,
      """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> уснул в позе "Будда Конасана".</i>
      """,
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> ложится спать</i>"
    ],
    going_out:
      "<i><%= CatName.fetch(:dative, true) %> наскучило сидеть дома, и он вышел на улицу прогуляться.</i>",
    want_care: [
      """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> трется о ногу <%= Member.full_name(who) %> и мурчит.</i>
      """,
      """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> настойчиво следует за <%= Member.full_name(who) %>.</i>
      """,
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> громко мяукает в другой комнате.</i>",
      """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> принес к ногам <%= Member.full_name(who) %> мышь... игрушечную, к счастью.</i>
      """,
      """
      <i><%= CatName.fetch(:nominative, true, cat.name) %> кружит вокруг <%= Member.full_name(who) %>.</i>
      """,
      "<i><%= CatName.fetch(:nominative, true, cat.name) %> зазывно мяучит.</i>"
    ],
    sad: "Мямямяууууу...",
    cat_is_back: "<%= CatName.fetch(:nominative, true, cat.name) %> вернулся домой.",
    feeder_consume: """
    <i><%= CatName.fetch(:nominative, true, cat.name) %> съедает из кормушки</i> <b><%= food %>.</b>
    """,
    laziness: %{
      1 => "сама надоедливость!",
      2 => "фантастически надоедлив!",
      4 => "очень надоедлив!",
      8 => "весьма надоедлив.",
      16 => "немного надоедлив.",
      32 => "слегка надоедлив.",
      64 => "слегка ленив.",
      128 => "немного ленив.",
      256 => "весьма ленив.",
      512 => "очень ленив!",
      1024 => "фантастически ленив!",
    },
    help: """
    Это котик в телеграме! Кормите, гладьте и обнимайте его! Окутайте его любовью, и он ответит вам взаимностью.
    Наиболее полно раскрывает себя в чатах на несколько человек.
    Если вас раздражают комментарии кота на ваши сообщения, то котика можно прогнать, сказав «брысь». Чтобы вернуть всё как было, скажите «кскскс» :о)
    Если кот проявляет себя слишком часто или, наоборот, слишком редко, то это можно отрегулировать командами /become_lazy и /become_annoying.
    """,
    name_variants: %{
      nominative: [
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
      ],
      dative: [
        "коту",
        "котику",
        "котяре",
        "котофею",
        "котейке",
        "котэ",
        "кошаку",
        "мурчале",
        "его пушистому величеству",
        "мохнатому батону",
        "кисулькену",
        "котангенсу",
        "меховому цветку"
      ],
      accusative: [
        "кота",
        "котика",
        "котяру",
        "котофея",
        "котейку",
        "котэ",
        "кошака",
        "кисулькена",
        "котангенса"
      ],
      genitive: [
        "кота",
        "котика",
        "котяры",
        "котофея",
        "котейки",
        "котэ",
        "кошака",
        "мурчала",
        "его пушистого величества",
        "мохнатого батона",
        "кисулькена",
        "котангенса",
        "котострофы",
        "мехового цветка"
      ]
    }
  },
  real_name_probability: 0.6,
  triggers: %{
    attract: ["кс", "кис"],
    banish: ["брысь"],
    eat: ["жр", "съе", "куш"],
    mew: ["ня", "мя", "мур"],
    cat: ["кис", "кот", "кош", "кыс"],
    dog: ["пес", "пёс", "соб", "щен", "барб"]
  },
  schedule: %{
    tire: 3,
    hungry: 7,
    metabolic: 11,
    pine: 5
  }

import_config "#{Mix.env()}.exs"

if Mix.env() != :prod do
  import_config "secret.exs"
end
